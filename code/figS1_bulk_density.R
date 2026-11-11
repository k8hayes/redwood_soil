## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. S1 - Bulk density by depth
## --------------------------------------------------------------- ##
# Run after 00_load-lib.R and 04_carbon-stocks.R.
# Writes output/figures/FigS1_bulk_density.png
#
# Bulk density is dry mass divided by the full ring volume, so it is
# too low wherever a ring was only partly filled (mostly 0-5 cm).

carbon <- read.csv(here::here("data/processed/carbon_by_sample.csv"))

carbon$depth <- paste0(carbon$depth_top_cm, "-", carbon$depth_bottom_cm)
carbon$depth <- factor(carbon$depth,
                       levels = unique(carbon$depth[order(carbon$depth_top_cm)]))

bulk_density_plot <- ggplot(carbon, aes(x = depth, y = bulk_density_g_cm3)) +
  geom_boxplot(fill = "grey") +
  labs(x = "Depth (cm)", y = expression(Bulk~density~(g~cm^-3))) +
  background_grid() + panel_border()

save_plot(here::here("output/figures/FigS1_bulk_density.png"),
          bulk_density_plot)
