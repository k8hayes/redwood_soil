# comparing digestion to physical counting
# Figure S2
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())
library(here)

# comparing kmd to sieved charcoal
char_comparison <- read.csv(here('Data/comparison.csv'))

char_comparison[which(char_comparison$mgC_g > 100),]
  # EELS 01A - 188.095
  # WORF 02F - 134.249
char_comparison <- char_comparison[-which(char_comparison$mgC_g > 100),]

ggplot(char_comparison, aes(x = depth_category, y = mgC_g, fill = type)) +
  geom_boxplot()  +
  scale_fill_manual(name = "Method", 
                    values = c("#dfc27d", "#018571"),
                    labels = c("Digestion", "Physical")) + 
  labs(x = "Depth (cm)", y = "Charcoal Concentration (mg/g)", title = "Comparing methods of charcoal quantification") + 
  scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35"))

# export as "FigS2_method.png" # 630 by 372
