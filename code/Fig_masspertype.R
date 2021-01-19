# figure of PyC mass according to site type
library(ggplot2)
library(cowplot) | theme_set(theme_cowplot())
library(here)
library(tidyverse)

gm2 <- read.csv(here("Data/gm2all.csv"))

# renaming columns
gm2 <- gm2 %>%
  select(!site.name) %>% # getting rid of duplicate column
  rename("SITE" = "site.group", "SITE#" = "Site", "DEPTH" = "Depth", "PyC" = "PyC.g.m2","TYPE" = "site_type")

# plotting data
    gm2 %>%
      filter(TYPE != "valley mineral soil") %>%
      ggplot(aes(DEPTH, PyC, col = TYPE)) + geom_boxplot() + 
      scale_color_manual(values = c("#202020", "#E69F00", "#56B4E9"),
                         name = "Site Type:",
                         labels = c("Hillslope Mineral Soil", "Ridgetop Mineral Soil", "Valley Mineral Soil")) + 
      labs(x = "Depth (cm)", y = "Average Mass of PyC (g/m2)", title = "Mass of PyC across Site Types") + 
      scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35"))
    