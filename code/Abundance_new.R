library(tidyverse)
library(cowplot) 
theme_set(theme_cowplot())
library(here)

costech <- read.csv("data/costech_results.csv")

names(costech)

costech <- costech %>%
  rename("depth" = "depth_category",
         "start_weight" = "starting_weight",
         "digest_weight" = "digested_weight")

data <- costech %>%
  filter(type != "std") %>%
  dplyr::select(!c(tin_weight, tray_number, N_percent, 
                   Del_C, Del_N, tray_number.1, Sample_id))

data <- data %>%
  filter(type == "kmd" | type == "raw") %>%
  pivot_wider(names_from = type,
              values_from = c(C_percent, start_weight, digest_weight,
                              sample_weight, mg.Carbon ))

# mg of PyC per gram of soil
data$PyC_mg <- (data$C_percent_kmd * data$digest_weight_kmd) / data$start_weight_kmd *1000 / 100
mean(data$PyC_mg)
sd(data$PyC_mg)

ggplot(data, aes(x = as.factor(site_name), y = PyC_mg)) + 
  geom_boxplot() + ylim(c(0, 20)) + 
  panel_border() + background_grid() + 
  geom_hline(yintercept = 5.12, linetype = "dotted", color = "red" ) + 
  labs(x = "Site", y = "mg of PyG per gram of soil", 
       title = "PyC Abundance") + 
  theme(axis.text.x = element_text(angle = 90))
