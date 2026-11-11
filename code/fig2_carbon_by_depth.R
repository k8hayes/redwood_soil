## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. 2 - Total carbon and pyrogenic share of carbon by depth
## --------------------------------------------------------------- ##
# Run after 00_load-lib.R and 04_carbon-stocks.R.
# Writes output/figures/Fig2_carbon_by_depth.png

carbon <- read.csv(here::here("data/processed/carbon_by_sample.csv"))

# Depth labels in order from the surface down
carbon$depth <- paste0(carbon$depth_top_cm, "-", carbon$depth_bottom_cm)
carbon$depth <- factor(carbon$depth,
                       levels = unique(carbon$depth[order(carbon$depth_top_cm)]))

carbon$pyc_percent_of_total <- carbon$pyc_fraction * 100

# A: total carbon concentration
total_c_plot <- ggplot(carbon, aes(x = depth, y = total_c_mg_g)) +
  geom_boxplot() +
  labs(x = "Depth (cm)", y = "Total C (mg per g soil)") +
  background_grid() + panel_border()

# B: pyrogenic carbon as a share of total carbon
pyc_share_plot <- ggplot(carbon, aes(x = depth, y = pyc_percent_of_total)) +
  geom_boxplot() +
  labs(x = "Depth (cm)", y = "Pyrogenic C (% of total C)") +
  background_grid() + panel_border()

fig2 <- plot_grid(total_c_plot, pyc_share_plot, labels = c("A", "B"))

save_plot(here::here("output/figures/Fig2_carbon_by_depth.png"), fig2,
          nrow = 1, ncol = 2)
