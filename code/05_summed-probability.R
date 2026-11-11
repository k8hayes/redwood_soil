## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 05 - Summed probability distribution of charcoal dates
## --------------------------------------------------------------- ##
# Sums the calibrated probability of the mineral-soil charcoal dates.
# The curve shows where surviving, dated charcoal is concentrated in
# time. It is not a fire-frequency curve: older charcoal is lost to
# fragmentation, decay and soil movement.
#
# Run after 02_calibrate-dates.R. Writes:
#   output/tables/summed_probability.csv
#   output/figures/Fig4_summed_probability.png
#
# Requires rcarbon, ggplot2, cowplot and here (called with pkg::).

# Parameters ###############################
calibration_curve <- "intcal20"
time_range_cal_bp <- c(4500, 0)   # oldest mineral-soil date is about 4,200
bin_width_years   <- 100          # dates from one site within this many
                                  # 14C years count as one event
mass_movement_types <- c("colluvial hollow", "alluvial fan")

# Dates ###############################
dates <- read.csv(here::here("data/processed/dates_calibrated.csv"),
                  stringsAsFactors = FALSE)

# Modern (post-1950) dates cannot be calibrated here and are left out.
mineral <- dates[!dates$site_type %in% mass_movement_types & !dates$is_modern, ]

message("Mineral-soil dates in the summed probability: ", nrow(mineral),
        " from ", length(unique(mineral$site_id)), " sites")
message("Modern mineral-soil dates left out: ",
        sum(dates$is_modern & !dates$site_type %in% mass_movement_types))

# Calibrate without normalising each date, then sum ###############################
calibrated <- rcarbon::calibrate(x = mineral$c14_age,
                                 errors = mineral$c14_error,
                                 ids = mineral$cams_id,
                                 calCurves = calibration_curve,
                                 normalised = FALSE,
                                 verbose = FALSE)

# binPrep() does not accept underscores in site names.
site_bins <- rcarbon::binPrep(sites = gsub("_", "-", mineral$site_id),
                              ages = mineral$c14_age,
                              h = bin_width_years)

spd_binned <- rcarbon::spd(calibrated, timeRange = time_range_cal_bp,
                           bins = site_bins, spdnormalised = FALSE,
                           verbose = FALSE)
spd_unbinned <- rcarbon::spd(calibrated, timeRange = time_range_cal_bp,
                             spdnormalised = FALSE, verbose = FALSE)

message("Bins (site-level events): ", length(unique(site_bins)))

summed <- data.frame(
  cal_bp = spd_binned$grid$calBP,
  density_binned_by_site = spd_binned$grid$PrDens,
  density_unbinned = spd_unbinned$grid$PrDens
)

write.csv(summed, here::here("output/tables/summed_probability.csv"),
          row.names = FALSE)

# Share of the summed probability in the last 1,000 years
share_last_1000 <- sum(summed$density_binned_by_site[summed$cal_bp <= 1000]) /
  sum(summed$density_binned_by_site)
message("Share of binned summed probability at or after 1000 cal BP: ",
        round(share_last_1000 * 100), "%")

# Figure ###############################
spd_plot <- ggplot2::ggplot(summed, ggplot2::aes(x = cal_bp)) +
  ggplot2::geom_area(ggplot2::aes(y = density_binned_by_site),
                     fill = "grey70") +
  ggplot2::geom_line(ggplot2::aes(y = density_unbinned), linetype = "dashed") +
  ggplot2::geom_rug(data = mineral, ggplot2::aes(x = cal_bp_median),
                    sides = "b") +
  ggplot2::scale_x_reverse() +
  ggplot2::labs(x = "Calibrated age (cal yr BP)",
                y = "Summed probability") +
  cowplot::theme_cowplot()

ggplot2::ggsave(here::here("output/figures/Fig4_summed_probability.png"),
                spd_plot, width = 7, height = 4, dpi = 300)
