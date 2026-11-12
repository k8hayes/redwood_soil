## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 01 - Calibrate radiocarbon dates
## --------------------------------------------------------------- ##
# Reads the master date table, calibrates every conventional age with
# rcarbon, and writes:
#   data/processed/dates_calibrated.csv        one row per date
#   output/tables/table1_radiocarbon_dates.csv Table 1 of the manuscript
#   output/tables/calibration_old_vs_new.csv   new values next to the
#                                              earlier CALIB output
#   output/tables/excluded_dates.csv           calibrated values for dates
#                                              not used in the analysis
#   output/tables/radiocarbon_summary.csv      counts and ages quoted in
#                                              the text
#
# Requires the rcarbon and here packages (called with pkg:: below).

# Parameters ###############################
calibration_curve <- "intcal20"
credible_mass     <- 0.954  # 2 sigma, to match the earlier CALIB output
collection_year   <- 2016   # latest possible year for a "modern" date
flag_shift_years  <- 25     # flag old-vs-new median shifts larger than this

# Output folders are created if they do not exist yet.
dir.create(here::here("data/processed"), showWarnings = FALSE)
dir.create(here::here("output/tables"), recursive = TRUE, showWarnings = FALSE)

# Read and check the master table ###############################
dates_raw <- read.csv(here::here("data/raw/radiocarbon_dates.csv"),
                      stringsAsFactors = FALSE)

stopifnot(!anyDuplicated(dates_raw$cams_id))
stopifnot(is.logical(dates_raw$use_in_analysis))

dates_excluded <- dates_raw[!dates_raw$use_in_analysis, ]
dates <- dates_raw[dates_raw$use_in_analysis, ]

# A modern date has no conventional age (the laboratory reported ">modern").
dates$is_modern <- is.na(dates$c14_age)

message("Dates in master table: ", nrow(dates_raw))
message("Excluded (use_in_analysis = FALSE): ", nrow(dates_excluded))
message("Modern dates (not calibrated): ", sum(dates$is_modern))
message("Dates to calibrate: ", sum(!dates$is_modern))

# Calibrate ###############################
to_calibrate <- dates[!dates$is_modern, ]

calibrated <- rcarbon::calibrate(x = to_calibrate$c14_age,
                                 errors = to_calibrate$c14_error,
                                 ids = to_calibrate$cams_id,
                                 calCurves = calibration_curve,
                                 normalised = TRUE,
                                 verbose = FALSE)

# hpdi() returns one matrix per date; each row is one calibrated range.
# Table 1 reports the full span: youngest and oldest bound across ranges.
ranges <- rcarbon::hpdi(calibrated, credMass = credible_mass)

to_calibrate$cal_bp_youngest <- sapply(ranges, function(r) min(r[, "endCalBP"]))
to_calibrate$cal_bp_oldest   <- sapply(ranges, function(r) max(r[, "startCalBP"]))
to_calibrate$cal_bp_median   <- rcarbon::medCal(calibrated)
to_calibrate$n_ranges        <- sapply(ranges, nrow)

# Modern dates ###############################
# rcarbon has no post-bomb curve, so modern dates are not calibrated here.
# They are bounded by 1950 (0 cal BP) and the collection year, and have
# no median.
modern <- dates[dates$is_modern, ]
modern$cal_bp_youngest <- 1950 - collection_year
modern$cal_bp_oldest   <- 0
modern$cal_bp_median   <- NA
modern$n_ranges        <- NA

dates_calibrated <- rbind(to_calibrate, modern)
dates_calibrated <- dates_calibrated[order(dates_calibrated$site_id,
                                           dates_calibrated$depth_cm,
                                           dates_calibrated$cams_id), ]

write.csv(dates_calibrated,
          here::here("data/processed/dates_calibrated.csv"),
          row.names = FALSE)

# Table 1 ###############################
table1 <- data.frame(
  site_id   = dates_calibrated$site_id,
  site_type = dates_calibrated$site_type,
  cams_id   = dates_calibrated$cams_id,
  depth_cm  = dates_calibrated$depth_cm,
  c14_age   = ifelse(dates_calibrated$is_modern, ">Modern",
                     dates_calibrated$c14_age),
  c14_error = dates_calibrated$c14_error,
  cal_bp_2sigma_range = ifelse(dates_calibrated$is_modern, "post-1950",
                               paste0(dates_calibrated$cal_bp_youngest, "-",
                                      dates_calibrated$cal_bp_oldest)),
  cal_bp_median = dates_calibrated$cal_bp_median
)

write.csv(table1,
          here::here("output/tables/table1_radiocarbon_dates.csv"),
          row.names = FALSE, na = "")

# Compare with the earlier CALIB output ###############################
# The archived CALIB output has two rows per date (1 sigma, then 2 sigma). Columns
# 9-26 hold up to six ranges as (lower, upper, relative area); the last
# column is the median probability.
calib_old <- read.csv(here::here("data/archive/calibration_calib/calout.csv"), header = FALSE, skip = 1)
calib_old <- calib_old[calib_old[[7]] == 2, ]

lower_columns <- seq(9, 24, by = 3)
upper_columns <- seq(10, 25, by = 3)

old <- data.frame(
  cams_id          = calib_old[[1]],
  old_cal_youngest = apply(calib_old[, lower_columns], 1, min, na.rm = TRUE),
  old_cal_oldest   = apply(calib_old[, upper_columns], 1, max, na.rm = TRUE),
  old_cal_median   = calib_old[[27]]
)

comparison <- merge(
  dates_calibrated[!dates_calibrated$is_modern,
                   c("cams_id", "site_id", "depth_cm", "c14_age", "c14_error",
                     "cal_bp_youngest", "cal_bp_oldest", "cal_bp_median")],
  old, by = "cams_id", all.x = TRUE)

comparison$shift_youngest <- comparison$cal_bp_youngest - comparison$old_cal_youngest
comparison$shift_oldest   <- comparison$cal_bp_oldest - comparison$old_cal_oldest
comparison$shift_median   <- comparison$cal_bp_median - comparison$old_cal_median
comparison$flag <- abs(comparison$shift_median) > flag_shift_years |
  abs(comparison$shift_youngest) > flag_shift_years |
  abs(comparison$shift_oldest) > flag_shift_years

comparison <- comparison[order(comparison$site_id, comparison$depth_cm), ]

write.csv(comparison,
          here::here("output/tables/calibration_old_vs_new.csv"),
          row.names = FALSE)

message("Dates with no earlier CALIB value: ",
        sum(is.na(comparison$old_cal_median)))
message("Dates where a bound or the median moved more than ",
        flag_shift_years, " years: ", sum(comparison$flag, na.rm = TRUE))

# Dates not used in the analysis ###############################
# Calibrated so the text can report them (the Headwaters Pond basal date).
if (nrow(dates_excluded) > 0) {
  excluded_calibrated <- rcarbon::calibrate(x = dates_excluded$c14_age,
                                            errors = dates_excluded$c14_error,
                                            ids = dates_excluded$cams_id,
                                            calCurves = calibration_curve,
                                            normalised = TRUE,
                                            verbose = FALSE)
  excluded_ranges <- rcarbon::hpdi(excluded_calibrated, credMass = credible_mass)

  dates_excluded$cal_bp_youngest <- sapply(excluded_ranges,
                                           function(r) min(r[, "endCalBP"]))
  dates_excluded$cal_bp_oldest   <- sapply(excluded_ranges,
                                           function(r) max(r[, "startCalBP"]))
  dates_excluded$cal_bp_median   <- rcarbon::medCal(excluded_calibrated)
}

write.csv(dates_excluded, here::here("output/tables/excluded_dates.csv"),
          row.names = FALSE)

# Numbers quoted in the text ###############################
# Modern dates stay in Table 1 but are not counted here: no fire is known
# at those sites after 1950, so they are not interpreted as fires.
mass_movement_types <- c("colluvial hollow", "alluvial fan")
is_mass_movement <- dates_calibrated$site_type %in% mass_movement_types
mineral <- dates_calibrated[!is_mass_movement & !dates_calibrated$is_modern, ]
mass_movement <- dates_calibrated[is_mass_movement, ]

radiocarbon_summary <- data.frame(
  quantity = c("dates in Table 1",
               "mineral-soil dates in Table 1",
               "modern mineral-soil dates (not counted below)",
               "calibrated mineral-soil dates",
               "calibrated mineral-soil dates with median <= 1000 cal BP",
               "oldest mineral-soil median (cal BP)",
               "oldest mineral-soil 2-sigma bound (cal BP)",
               "mass-movement dates",
               "youngest mass-movement median (cal BP)",
               "oldest mass-movement median (cal BP)"),
  value = c(nrow(dates_calibrated),
            sum(!is_mass_movement),
            sum(!is_mass_movement & dates_calibrated$is_modern),
            nrow(mineral),
            sum(mineral$cal_bp_median <= 1000),
            max(mineral$cal_bp_median),
            max(mineral$cal_bp_oldest),
            nrow(mass_movement),
            min(mass_movement$cal_bp_median),
            max(mass_movement$cal_bp_median))
)

write.csv(radiocarbon_summary,
          here::here("output/tables/radiocarbon_summary.csv"),
          row.names = FALSE)

print(radiocarbon_summary)
