## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. 3 - Age depth relationships
## --------------------------------------------------------------- ##
# Code written by: Kate Hayes (hayesk7@wwu.edu)
# Fall 2026

# figure 3A 

dates <- read.csv(here("data/dates.csv"))

dates$median_cal_age = as.numeric(dates$median_cal_age)

dates = dates %>%
  mutate(median_cal_age = ifelse(median_cal_age == "NA", 0, median_cal_age))

site_labels <- c("Alluvial Fan",
                 "Colluvial Hollow",
                 "Hillslope Mineral Soil",
                 "Ridgetop Mineral Soil",
                 "Valley Mineral Soil")

site_cols = c("#543005", "#bf812d", 
              "#c7eae5", "#35978f", "#003c30")


age_p = ggplot(dates) +
  geom_point(aes(x = median_cal_age, y = depth, col= site_type, fill = site_type, shape = site_type), 
             alpha = 0.7, size = 3) +
  geom_errorbar(aes(xmin = median_cal_age - error,
                    xmax = median_cal_age + error,
                    y = depth, col = site_type)) +
  scale_y_reverse() + scale_x_reverse() + 
  scale_fill_manual(labels = site_labels, values = site_cols) +
  scale_color_manual(labels = site_labels, values = site_cols) +
  scale_shape_manual(values = c(23, 21, 24, 24, 24)) + 
  background_grid() + panel_border() + 
  labs(y = "Depth (cm)", x = "Calibrated radiocarbon age (yr)",
       title = "Age of charcoal by depth") +
  theme(legend.position = "none")

age_p

# Figure 3B. Age-depth reversal

reverse = read.csv(here("data/age_reverse.csv"), header = TRUE)

agereverse_p = ggplot(reverse) +
  geom_point(aes(x = depth_reversal, y = age_reversal,
                 col = site_type, fill = site_type, shape = site_type),
             alpha = 0.8, size = 3) +
  background_grid() + panel_border() +
  scale_shape_manual(values = c(23, 21, 24, 24, 24), labels = site_labels) +
  scale_fill_manual(labels = site_labels, values = site_cols) +
  scale_color_manual(labels = site_labels, values = site_cols) +
  geom_hline(yintercept = 0) +
  labs(y = "Difference in age (year)",
       x = "Difference in depth (cm)",
       title = "Charcoal Stratigraphy",
       fill = "Site Type",
       colour = "Site Type",
       shape = "Site Type") 

agereverse_p = agereverse_p + 
  annotate("text", y = 4000, x = 80, label = "No Age Reversal") +
  annotate("text", y = -4000, x = 85, label = "Age Reversal")

agereverse_p

fig3 = plot_grid(age_p, agereverse_p, nrow = 1, ncol = 2, rel_widths = c(0.8, 1.2),
          labels = c("A.", "B.")) 

save_plot("output/figures/Fig3_agedepth.png", fig3, nrow = 1, ncol = 2)
