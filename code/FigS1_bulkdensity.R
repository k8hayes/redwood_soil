# script for producing bulk density graph
# appendix 1: figure s1
library(ggplot2)
library(here)
library(cowplot)
theme_set(theme_cowplot())

char_mass <- read.csv(here("Data/char_mass_sieve.csv"))

# calculating the volume of the soil rings used
ring_volume <- pi * 2.5^2 * 5 # 98.17477

# adding column to char_mass for bulk density
char_mass$bulk_density <- char_mass$kmd_dry_weight/ring_volume 

# attaching order to depth
char_mass$depth <- factor(depth, levels = c("0-5", "5-10", "10-15",
                                            "15-20", "20-25", "25-30", "30-35"))
# changing depth to cm
char_mass$depth[char_mass$depth_category == "A"] <- "0-5"
char_mass$depth[char_mass$depth_category == "B"] <- "5-10"
char_mass$depth[char_mass$depth_category == "C"] <- "10-15"
char_mass$depth[char_mass$depth_category == "D"] <- "15-20"
char_mass$depth[char_mass$depth_category == "E"] <- "20-25"
char_mass$depth[char_mass$depth_category == "F"] <- "25-30"
char_mass$depth[char_mass$depth_category == "G"] <- "30-35"

# exploring relationship between bulk density and depth
ggplot(char_mass) + geom_boxplot(aes(depth, bulk_density), fill = "grey") + 
  labs(x = "Depth (cm)", y = "Bulk Density (Grams per cm3)",
       title = "Bulk Density across Depth") + 
  background_grid() + panel_border()

# save as "FigS1_bulkdensity.png" # 450 x 400

