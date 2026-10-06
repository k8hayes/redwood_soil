## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 01 - Process costech results
## --------------------------------------------------------------- ##
# Code written by: Kate Hayes (khayes23@alaska.edu)
# Fall 2026


# Figure 2

costech = read.csv("data/processed/costech_results_process.csv")


# Figure 1A #################################################
undigest <- costech %>%
  filter(type == "raw")

colnames(undigest)

undigest$depth <- factor(undigest$depth, ordered = TRUE,
                        levels = c("0-5", "5-10", "10-15",
                                   "15-20", "20-25", "25-30"))

plotA <- ggplot(undigest, aes(x = depth, y = mg.Carbon)) + geom_boxplot() + 
  labs(x = "Depth (cm)", y = "Carbon (g) per gram of soil", title = "Total Soil Carbon across depth") + 
  panel_border() + background_grid()

plotA
              
# Figure 1B ##############################

ratio <- costech %>% 
  dplyr::select(c(site, site_name, depth, type, site_type, C_percent)) %>%
  pivot_wider(names_from = type, values_from = C_percent)

ratio$ratio_per <- (ratio$kmd / ratio$raw) * 100

ratio$depth <- factor(ratio$depth, ordered = TRUE,
                         levels = c("0-5", "5-10", "10-15",
                                    "15-20", "20-25", "25-30"))

plotB <- ggplot(ratio, aes(x = depth, y = ratio_per) ) + geom_boxplot() + 
  labs(x = "Depth (cm)", y = "Ratio (%)", 
       title = "Ratio of Pyrogenic C to Total C") +
  panel_border() + background_grid()

plotB

ab_plot = plot_grid(plotA, plotB, rel_widths = c(1,1), labels = c("A.", "B."))

save_plot("output/figures/Fig2_carbonratio.png", ab_plot, nrow = 1, ncol = 2)
