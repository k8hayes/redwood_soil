# averaging charcoal per site and per depth
library(tidyverse)
library(here)
library(cowplot)
theme_set(theme_cowplot())
  
char_mass <- read.csv(here("data/char_mass_sieve.csv"))

# lets make variables easier
sample_depth <- char_mass$depth..mm.
total_mass <- char_mass$total.mass

# with outliers
boxplot_outliers <- ggplot(char_mass, aes(char_mass$sample_id, total.mass))
boxplot_outliers + geom_boxplot(aes(group = cut_width(char_mass$sample_id, 1)), fill = "grey") + labs(title = "Average mass of charcoal per depth (sieving)", x = "Sample depth category", y = "Total mass of charoal (g)")

# testing stack overflow answer to removing outliers
  # create boxplot that includes outliers
  p0 = ggplot(char_mass, aes(y = char_mass$total.mass), title = "Average mass of charcoal per depth") + geom_boxplot(aes(x = char_mass$sample_id), fill = "grey")
  # compute lower and upper whiskers
  sts = boxplot.stats(char_mass$total.mass)$stats
  # scale y limits based on ylim1
  boxplot = p0 + coord_cartesian(ylim = c(sts[2]/2,max(sts)*1.05))
boxplot + labs(title = "Average mass of charcoal per depth (sieving)", subtitle = "Plotted without outliers", x = "Sample depth category", y = "Total mass of charoal (g)") # no outliers

p2 = ggplot(char_mass, aes(char_mass$total.mass)) 
    + geom_boxplot(aes(char_mass$sample_id), varwidth = TRUE)

