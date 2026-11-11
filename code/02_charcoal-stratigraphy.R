## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 02 - Charcoal stratigraphy (age-depth pairs)
## --------------------------------------------------------------- ##
# Builds every pair of dates from adjacent depths within a site and
# classifies each pair from the calibrated 2-sigma ranges:
#   in order          deeper date is older and the ranges do not overlap
#   reversed          deeper date is younger and the ranges do not overlap
#   indistinguishable the ranges overlap
# Dates from the same depth are never paired with each other. Where a
# depth has two dates, each is paired with every date at the next depth.
# The age difference uses calibrated medians; a modern date has no median,
# so the midpoint of its post-1950 bounds is used instead.
#
# Run after 01_calibrate-dates.R. Writes:
#   data/processed/stratigraphy_pairs.csv     one row per pair
#   output/tables/stratigraphy_summary.csv    counts by site type and class
#   output/tables/stratigraphy_old_vs_new.csv pairs whose class differs
#                                             under the earlier calibration

# Functions ###############################

# All pairs of dates from adjacent depth levels within one site.
pairs_for_site <- function(site_dates) {
  depth_levels <- sort(unique(site_dates$depth_cm))
  if (length(depth_levels) < 2) return(NULL)

  site_pairs <- list()
  for (i in seq_len(length(depth_levels) - 1)) {
    shallow <- site_dates[site_dates$depth_cm == depth_levels[i], ]
    deep    <- site_dates[site_dates$depth_cm == depth_levels[i + 1], ]
    combos  <- expand.grid(s = seq_len(nrow(shallow)), d = seq_len(nrow(deep)))

    site_pairs[[i]] <- data.frame(
      site_id          = shallow$site_id[1],
      site_type        = shallow$site_type[1],
      shallow_cams_id  = shallow$cams_id[combos$s],
      deep_cams_id     = deep$cams_id[combos$d],
      shallow_depth_cm = shallow$depth_cm[combos$s],
      deep_depth_cm    = deep$depth_cm[combos$d],
      shallow_youngest = shallow$youngest[combos$s],
      shallow_oldest   = shallow$oldest[combos$s],
      shallow_median   = shallow$median[combos$s],
      deep_youngest    = deep$youngest[combos$d],
      deep_oldest      = deep$oldest[combos$d],
      deep_median      = deep$median[combos$d]
    )
  }
  do.call(rbind, site_pairs)
}

# Pairs for all sites, classified. The three column names say which
# calibrated bounds to use, so the same code runs on old and new values.
build_pairs <- function(dates, youngest_column, oldest_column, median_column) {
  dates$youngest <- dates[[youngest_column]]
  dates$oldest   <- dates[[oldest_column]]
  dates$median   <- dates[[median_column]]
  no_median <- is.na(dates$median)
  dates$median[no_median] <- (dates$youngest[no_median] + dates$oldest[no_median]) / 2

  by_site <- split(dates, dates$site_id)
  pairs <- do.call(rbind, lapply(by_site, pairs_for_site))
  rownames(pairs) <- NULL

  pairs$depth_difference_cm <- pairs$deep_depth_cm - pairs$shallow_depth_cm
  pairs$median_difference   <- pairs$deep_median - pairs$shallow_median

  pairs$class <- "indistinguishable"
  pairs$class[pairs$deep_youngest > pairs$shallow_oldest] <- "in order"
  pairs$class[pairs$deep_oldest < pairs$shallow_youngest] <- "reversed"
  pairs
}

# Read ###############################
dates <- read.csv(here::here("data/processed/dates_calibrated.csv"),
                  stringsAsFactors = FALSE)

mass_movement_types <- c("colluvial hollow", "alluvial fan")
dates$setting <- ifelse(dates$site_type %in% mass_movement_types,
                        "mass movement", "mineral soil")

# Pairs from the new calibration ###############################
pairs <- build_pairs(dates, "cal_bp_youngest", "cal_bp_oldest", "cal_bp_median")
pairs$setting <- ifelse(pairs$site_type %in% mass_movement_types,
                        "mass movement", "mineral soil")

write.csv(pairs, here::here("data/processed/stratigraphy_pairs.csv"),
          row.names = FALSE)

summary_table <- as.data.frame(table(setting = pairs$setting,
                                     site_type = pairs$site_type,
                                     class = pairs$class),
                               responseName = "n_pairs")
summary_table <- summary_table[summary_table$n_pairs > 0, ]

write.csv(summary_table,
          here::here("output/tables/stratigraphy_summary.csv"),
          row.names = FALSE)

message("Pairs by setting and class:")
print(table(pairs$setting, pairs$class))

# Same classification under the earlier calibration ###############################
old <- read.csv(here::here("output/tables/calibration_old_vs_new.csv"))
dates_old <- merge(dates, old[, c("cams_id", "old_cal_youngest",
                                  "old_cal_oldest", "old_cal_median")],
                   by = "cams_id", all.x = TRUE)

# Modern dates keep their post-1950 bounds; they were never in CALIB.
dates_old$old_cal_youngest[dates_old$is_modern] <- dates_old$cal_bp_youngest[dates_old$is_modern]
dates_old$old_cal_oldest[dates_old$is_modern]   <- dates_old$cal_bp_oldest[dates_old$is_modern]

pairs_old <- build_pairs(dates_old, "old_cal_youngest", "old_cal_oldest",
                         "old_cal_median")

class_comparison <- merge(
  pairs[, c("site_id", "shallow_cams_id", "deep_cams_id", "class")],
  pairs_old[, c("shallow_cams_id", "deep_cams_id", "class")],
  by = c("shallow_cams_id", "deep_cams_id"),
  suffixes = c("_new", "_old"))

class_changed <- class_comparison[class_comparison$class_new !=
                                    class_comparison$class_old, ]

write.csv(class_changed,
          here::here("output/tables/stratigraphy_old_vs_new.csv"),
          row.names = FALSE)

message("Pairs whose class differs under the earlier calibration: ",
        nrow(class_changed))
