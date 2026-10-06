# running a paired t-test on manual vs chemical estimates

# Set up ######################
library(tidyverse)
library(here)
library(rstatix)
options(scipen = 9999)

data_row <- read.csv(here('Data/comparison.csv'))

data_row <- data_row %>%
  rename("depth" = "depth_category")

data_col <- data_row %>% 
  pivot_wider(names_from = type, values_from = mgC_g) 

data_col$diff <- data_col$kmd - data_col$sieved

shapiro.test(data_col$diff)

# Total dataset ###################################

data_col2 <- data_col %>%
  select(c(kmd,sieved))

summary(data_col2$kmd)
length(data_col2$kmd)
sd(data_col2$kmd)

summary(data_col2$sieved)
sd(data_col2$sieved)

wilcox.test(data_col2$kmd, data_col2$sieved, paired = TRUE, alternative = "two.sided")

data_row %>% wilcox_effsize(mgC_g ~ type)

# Splitting by depth ##########################################

## 0-5 #####################
    data_colA <- data_col %>%
      filter(depth == "A")
    
    length(data_colA$kmd)
    
    median(data_colA$kmd)
    sd(data_colA$kmd)
    
    median(data_colA$sieved)
    sd(data_colA$sieved)
    
    wilcox.test(data_colA$kmd, data_colA$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowA <- data_row %>%
      filter(depth == "A")
    
    data_rowA %>% wilcox_effsize(mgC_g ~ type)
    
## 5-10 #######################################
    data_colB <- data_col %>%
      filter(depth == "B")
    
    length(data_colB$kmd)
    
    median(data_colB$kmd)
    sd(data_colB$kmd)
    
    median(data_colB$sieved)
    sd(data_colB$sieved)
    
    wilcox.test(data_colB$kmd, data_colB$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowB <- data_row %>%
      filter(depth == "B")
    
    data_rowB %>% wilcox_effsize(mgC_g ~ type)
    
## 10-15 #######################################
    data_colC <- data_col %>%
      filter(depth == "C")
    
    length(data_colC$kmd)
    
    median(data_colC$kmd)
    sd(data_colC$kmd)
    
    median(data_colC$sieved)
    sd(data_colC$sieved)
    
    wilcox.test(data_colC$kmd, data_colC$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowC <- data_row %>%
      filter(depth == "C")
    
    data_rowC %>% wilcox_effsize(mgC_g ~ type)
    
## 15-20 ############################################
    data_colD <- data_col %>%
      filter(depth == "D")
    
    length(data_colD$kmd)
    
    median(data_colD$kmd)
    sd(data_colD$kmd)
    
    median(data_colD$sieved)
    sd(data_colD$sieved)
    
    wilcox.test(data_colD$kmd, data_colD$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowD <- data_row %>%
      filter(depth == "D")
    
    data_rowD %>% wilcox_effsize(mgC_g ~ type)
    
## 20-25 #####################
    data_colE <- data_col %>%
      filter(depth == "E")
    
    length(data_colE$kmd)
    
    median(data_colE$kmd)
    sd(data_colE$kmd)
    
    median(data_colE$sieved)
    sd(data_colE$sieved)
    
    wilcox.test(data_colE$kmd, data_colE$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowE <- data_row %>%
      filter(depth == "E")
    
    data_rowE %>% wilcox_effsize(mgC_g ~ type)
    
## 25-30 #####################
    data_colF <- data_col %>%
      filter(depth == "F")
    
    length(data_colF$kmd)
    
    median(data_colF$kmd)
    sd(data_colF$kmd)
    
    median(data_colF$sieved)
    sd(data_colF$sieved)
    
    wilcox.test(data_colF$kmd, data_colF$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowF <- data_row %>%
      filter(depth == "F")
    
    data_rowF %>% wilcox_effsize(mgC_g ~ type)
    
## 30-35 #####################
    data_colG <- data_col %>%
      filter(depth == "G")
    
    length(data_colG$kmd)
    
    median(data_colG$kmd)
    sd(data_colG$kmd)
    
    median(data_colG$sieved)
    sd(data_colG$sieved)
    
    wilcox.test(data_colG$kmd, data_colG$sieved,
                paired = TRUE, alternative = "two.sided")
    
    data_rowG <- data_row %>%
      filter(depth == "G")
    
    data_rowG %>% wilcox_effsize(mgC_g ~ type)    
    
