## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. S2 - Sieved charcoal against digestion, by depth
## --------------------------------------------------------------- ##
# Run after 00_load-lib.R and 04_carbon-stocks.R. Writes:
#   data/processed/method_comparison.csv
#   output/tables/method_comparison_by_depth.csv
#   output/figures/FigS2_method_comparison.png
#
# The two methods measure different things: sieving gives the mass of
# charcoal pieces larger than 0.5 mm; digestion gives the mass of
# pyrogenic carbon of any size. Sieved samples were never dried and
# weighed, so their concentration uses the dry mass of the paired
# digestion core from the same site and depth.

rings_used <- c("A", "B", "C", "D", "E", "F")  # 0-30 cm

# Sieved charcoal mass per sample (g), summed over both sieve sizes
sieved <- read.csv(here::here("data/raw/sieved_charcoal_mass.csv"),
                   fileEncoding = "UTF-8-BOM")
sieved <- sieved[sieved$depth_category %in% rings_used,
                 c("Site_id", "depth_category", "total_mass")]
names(sieved) <- c("site_id", "ring", "sieved_charcoal_g")

# Digestion results and dry mass per sample
carbon <- read.csv(here::here("data/processed/carbon_by_sample.csv"))
carbon <- carbon[, c("site_id", "ring", "depth_top_cm", "depth_bottom_cm",
                     "dry_mass_g", "pyc_mg_g")]

comparison <- merge(carbon, sieved, by = c("site_id", "ring"))
stopifnot(nrow(comparison) == nrow(carbon))

comparison$sieved_charcoal_mg_g <- comparison$sieved_charcoal_g * 1000 /
  comparison$dry_mass_g

comparison <- comparison[order(comparison$site_id, comparison$depth_top_cm), ]
write.csv(comparison, here::here("data/processed/method_comparison.csv"),
          row.names = FALSE)

# Means per depth increment
by_depth <- aggregate(cbind(pyc_mg_g, sieved_charcoal_mg_g) ~ depth_top_cm +
                        depth_bottom_cm,
                      data = comparison, FUN = mean)
by_depth <- by_depth[order(by_depth$depth_top_cm), ]
write.csv(by_depth, here::here("output/tables/method_comparison_by_depth.csv"),
          row.names = FALSE)

# Long format for plotting: one row per sample and method
plot_data <- rbind(
  data.frame(depth_top_cm = comparison$depth_top_cm,
             depth_bottom_cm = comparison$depth_bottom_cm,
             method = "Digestion (pyrogenic C)",
             concentration_mg_g = comparison$pyc_mg_g),
  data.frame(depth_top_cm = comparison$depth_top_cm,
             depth_bottom_cm = comparison$depth_bottom_cm,
             method = "Sieving (charcoal > 0.5 mm)",
             concentration_mg_g = comparison$sieved_charcoal_mg_g)
)

plot_data$depth <- paste0(plot_data$depth_top_cm, "-", plot_data$depth_bottom_cm)
plot_data$depth <- factor(plot_data$depth,
                          levels = unique(plot_data$depth[order(plot_data$depth_top_cm)]))

method_plot <- ggplot(plot_data, aes(x = depth, y = concentration_mg_g,
                                     fill = method)) +
  geom_boxplot() +
  scale_fill_manual(name = "Method", values = c("#bdbdbd", "#f0f0f0")) +
  labs(x = "Depth (cm)", y = "Concentration (mg per g soil)") +
  background_grid() + panel_border(color = "black")

save_plot(here::here("output/figures/FigS2_method_comparison.png"),
          method_plot, base_asp = 1.9)
