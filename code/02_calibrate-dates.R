## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 02 - Calibrate radiocarbon dates
## --------------------------------------------------------------- ##
# Reads the master date table, calibrates every conventional age with
# rcarbon, and writes:
#   data/processed/dates_calibrated.csv        one row per date
#   output/tables/table1_radiocarbon_dates.csv Table 1 of the manuscript
#   output/tables/calibration_old_vs_new.csv   new values next to the
#                                              earlier CALIB output
#
# Requires the rcarbon and here packages (called with pkg:: below).

# Parameters ###############################
calibration_curve <- "intcal20"
credible_mass     <- 0.954  # 2 sigma, to match the earlier CALIB output
collection_year   <- 2016   # latest possible year for a "modern" date
flag_shift_years  <- 25     # flag old-vs-new median shifts larger than this

dir.create(here::here("output/tables"), showWarnings = FALSE)

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
# data/calout.csv has two rows per date (1 sigma, then 2 sigma). Columns
# 9-26 hold up to six ranges as (lower, upper, relative area); the last
# column is the median probability.
calib_old <- read.csv(here::here("data/calout.csv"), header = FALSE, skip = 1)
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
