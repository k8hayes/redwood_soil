# averaging charcoal per site and per depth
setwd(dir = "Desktop/Thesis/Data/")
char_mass <- read.csv(file = "char_mass_sieve.csv")

# collecting by site
  a_index <- which(char_mass$sample_id == "A")
  a_mass <- char_mass[a_index,]
  a_mean <- mean(a_mass$total.mass)
  a_sd <- sd(a_mass$total.mass)
  
  
  b_index <- which(char_mass$sample_id == "B")
  b_mass <- char_mass[b_index,]
  b_mean <- mean(b_mass$total.mass)
  b_sd <- sd(b_mass$total.mass)
  
  C_index <- which(char_mass$sample_id == "C")
  c_mass <- char_mass[C_index,]
  c_mean <- mean(c_mass$total.mass)
  c_sd <- sd(c_mass$total.mass)
  
  d_index <- which(char_mass$sample_id == "D")
  d_mass <- char_mass[d_index,]
  d_mean <- mean(d_mass$total.mass)
  d_sd <- sd(d_mass$total.mass)
  
  e_index <- which(char_mass$sample_id == "E")
  e_mass <- char_mass[e_index,]
  e_mean <- mean(e_mass$total.mass)
  e_sd <- sd(e_mass$total.mass)
  
  f_index <- which(char_mass$sample_id == "F")
  f_mass <- char_mass[f_index,]
  f_mean <- mean(f_mass$total.mass)
  f_sd <- sd(f_mass$total.mass)
  
  g_index <- which(char_mass$sample_id == "G")
  g_mass <- char_mass[g_index,]
  g_mean <- mean(g_mass$total.mass)
  g_sd <- sd(g_mass$total.mass)
  
# working with those groupings 
averages <- c(a_mean, b_mean, c_mean, d_mean, e_mean, f_mean, g_mean)
totals <- c(a_mass, b_mass, c_mass, d_mass, e_mass, f_mass, g_mass)
SDs <- c(a_sd, b_sd, c_sd, d_sd, e_sd, f_sd, g_sd)
plot(averages)

# box plot of averages and depths
boxplot(char_mass$total.mass ~ char_mass$sample_id, data = char_mass)

# GGPLOT2
# install.packages("ggplot2")
library(ggplot2)
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


install.packages("cowplot")
