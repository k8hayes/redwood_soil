## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. 3 - Charcoal age by depth and age-depth pairs
## --------------------------------------------------------------- ##
# Run after 00_load-lib.R, 01_calibrate-dates.R and
# 02_charcoal-stratigraphy.R.
# Writes output/figures/Fig3_age_depth.png

site_labels <- c("alluvial fan"           = "Alluvial fan",
                 "colluvial hollow"       = "Colluvial hollow",
                 "hillslope mineral soil" = "Hillslope mineral soil",
                 "ridgetop mineral soil"  = "Ridgetop mineral soil",
                 "valley mineral soil"    = "Valley mineral soil")

site_colours <- c("alluvial fan"           = "#543005",
                  "colluvial hollow"       = "#bf812d",
                  "hillslope mineral soil" = "#c7eae5",
                  "ridgetop mineral soil"  = "#35978f",
                  "valley mineral soil"    = "#003c30")

site_shapes <- c("alluvial fan"           = 23,
                 "colluvial hollow"       = 21,
                 "hillslope mineral soil" = 24,
                 "ridgetop mineral soil"  = 24,
                 "valley mineral soil"    = 24)

# A: calibrated age against depth ###############################
# Points are calibrated medians; bars are the full 2-sigma range.
# Modern dates have no median and are drawn at the midpoint of their
# post-1950 bounds.
dates <- read.csv(here::here("data/processed/dates_calibrated.csv"))

dates$plot_age <- ifelse(dates$is_modern,
                         (dates$cal_bp_youngest + dates$cal_bp_oldest) / 2,
                         dates$cal_bp_median)

age_plot <- ggplot(dates, aes(y = depth_cm, colour = site_type)) +
  geom_linerange(aes(xmin = cal_bp_youngest, xmax = cal_bp_oldest)) +
  geom_point(aes(x = plot_age, fill = site_type, shape = site_type),
             alpha = 0.7, size = 3) +
  scale_x_reverse() + scale_y_reverse() +
  scale_colour_manual(values = site_colours, labels = site_labels) +
  scale_fill_manual(values = site_colours, labels = site_labels) +
  scale_shape_manual(values = site_shapes, labels = site_labels) +
  labs(x = "Calibrated age (cal yr BP)", y = "Depth (cm)") +
  background_grid() + panel_border() +
  theme(legend.position = "none")

# B: age difference against depth difference for each pair ###############################
# Above zero the deeper charcoal is older; below zero it is younger.
# Hollow points are pairs whose 2-sigma ranges overlap.
pairs <- read.csv(here::here("data/processed/stratigraphy_pairs.csv"))

pairs$distinguishable <- ifelse(pairs$class == "indistinguishable",
                                "Ranges overlap", "Ranges separate")

pair_plot <- ggplot(pairs, aes(x = depth_difference_cm, y = median_difference,
                               colour = site_type, shape = site_type)) +
  geom_hline(yintercept = 0) +
  geom_point(aes(fill = site_type, alpha = distinguishable), size = 3) +
  scale_colour_manual(values = site_colours, labels = site_labels) +
  scale_fill_manual(values = site_colours, labels = site_labels) +
  scale_shape_manual(values = site_shapes, labels = site_labels) +
  scale_alpha_manual(values = c("Ranges overlap" = 0.15, "Ranges separate" = 0.8)) +
  annotate("text", x = Inf, y = Inf, label = "Deeper is older",
           hjust = 1.1, vjust = 1.5) +
  annotate("text", x = Inf, y = -Inf, label = "Deeper is younger",
           hjust = 1.1, vjust = -0.8) +
  labs(x = "Difference in depth (cm)", y = "Difference in age (yr)",
       colour = "Site type", fill = "Site type", shape = "Site type",
       alpha = "Age ranges") +
  background_grid() + panel_border()

fig3 <- plot_grid(age_plot, pair_plot, nrow = 1, rel_widths = c(0.8, 1.2),
                  labels = c("A", "B"))

save_plot(here::here("output/figures/Fig3_age_depth.png"), fig3,
          nrow = 1, ncol = 2)
