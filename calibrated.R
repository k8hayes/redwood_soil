# plotting calibrated ages
setwd('/Users/katherinehayes/Desktop/Thesis/Data/')
calib <- read.csv('calout.csv')

hist(calib$median.probability)

  age_reversals <- read.csv('age_reversal.csv')
age_reversals
