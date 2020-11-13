library(ggplot2)
library(cowplot)

# comparing kmd to sieved charcoal
char_comparison <- read.csv('Desktop/Thesis/Data/costech/comparison.csv')


char_comparison[which(char_comparison$mgC_g > 100),]
  # EELS 01A - 188.095
  # WORF 02F - 134.249
char_comparison1 <- char_comparison[-which(char_comparison$mgC_g > 100),]

method_ggplot <- ggplot(char_comparison1, aes(x = char_comparison1$depth_category, y = char_comparison1$mgC_g, fill = char_comparison1$type)) +
  geom_boxplot() +
  background_grid() + panel_border() +
  scale_fill_manual(name = "Method", 
                    values = c("#dfc27d", "#018571"),
                    labels = c("Chemical", "Physical")) + 
  labs(x = "Depth (cm)", y = "Charcoal Concentration (mg/g)", title = "Comparing methods of charcoal quantification") + 
  scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35"))
method_ggplot

save_plot("method_ggplot.png", method_ggplot, base_aspect_ratio = 1.8)
