devtools::install_github("ahb108/rcarbon")

library(rcarbon)
library(tidyverse)
library(here)

data("euroevol")
colnames(euroevol)
class(euroevol)

data <- read.csv(here("data/bchron/red14_bchron.csv"))
colnames(data)

red_c14$C14ID <- data$site
red_c14$C14Age <- data$ages
red_c14$C14SD <- data$SD


red_caldates <- calibrate(data$ages, data$SD, calCurves = "intcal20")
min(data$ages)
max(data$ages)

test <- spd(red_caldates, timeRange = c(7500, 0), spdnormalised = FALSE)

plot(test)


plot(test, xlim = c(1500, 0))
abline(v = c(250, 255, 245, 215, 160, 180, 150, 145, 100, 75), col = "Red",
       lty = 2)
