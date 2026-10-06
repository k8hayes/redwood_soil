## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## S1 - Bulk density
## --------------------------------------------------------------- ##
# Code written by: Kate Hayes (khayes23@alaska.edu)
# Fall 2026

# script for producing bulk density graph
# appendix 1: figure s1

char_mass <- read.csv(here("data/char_mass_sieve.csv"))

# calculating the volume of the soil rings used
ring_volume <- pi * 2.5^2 * 5 # 98.17477 cm

# adding column to char_mass for bulk density
char_mass$bulk_den <- char_mass$kmd_dry_weight/ring_volume 

# attaching order to depth
char_mass$depth <- factor(char_mass$depth, levels = c("0-5", "5-10", "10-15",
                                            "15-20", "20-25", "25-30", "30-35"))
# changing depth to cm
char_mass$depth[char_mass$depth_category == "A"] <- "0-5"
char_mass$depth[char_mass$depth_category == "B"] <- "5-10"
char_mass$depth[char_mass$depth_category == "C"] <- "10-15"
char_mass$depth[char_mass$depth_category == "D"] <- "15-20"
char_mass$depth[char_mass$depth_category == "E"] <- "20-25"
char_mass$depth[char_mass$depth_category == "F"] <- "25-30"
char_mass$depth[char_mass$depth_category == "G"] <- "30-35"

char_mass <- char_mass %>%
  filter(depth != "30-35")

# exploring relationship between bulk density and depth
bd_plot = ggplot(char_mass) + geom_boxplot(aes(depth, bulk_den), fill = "grey") + 
  labs(x = "Depth (cm)", y = "Bulk Density (Grams per cm3)",
       title = "Bulk Density across Depth") + 
  background_grid() + panel_border()

# save as "FigS1_bulkdensity.png" # 450 x 400
save_plot("output/figures/FigS1_bulkdensity.png", bd_plot, nrow = 1, ncol = 1)


