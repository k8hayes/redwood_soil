## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. S2 - comparing digestion methods
## --------------------------------------------------------------- ##
# Code written by: Kate Hayes (hayesk7@wwu.edu)
# Fall 2026

# comparing digestion to physical counting
# Figure 2


# comparing kmd to sieved charcoal
char_comparison <- read.csv(here('data/comparison.csv'))

    char_comparison[which(char_comparison$mgC_g > 100),] # checking high numbers
      # EELS 01A - 188.095
      # WORF 02F - 134.249
    
  char_comparison <- char_comparison[-which(char_comparison$mgC_g > 100),] # taking them out
  
  char_comparison = char_comparison %>%
    filter(depth_category != "G")

# Depth Plot ######################  
# plotting according to depth
method_p <-  ggplot(char_comparison, aes(x = depth_category, y = mgC_g, fill = type)) +
    geom_boxplot()  +
    scale_fill_manual(name = "Method", 
                      values = c("#bdbdbd", "#f0f0f0"),
                      labels = c("Digestion", "Manual")) + 
    labs(x = "Depth (cm)", y = "Charcoal Concentration (mg/g)", 
         title = "Charcoal estimates by method") + 
    scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35")) +
    panel_border(color = "black") + background_grid()
    
  save_plot("output/figures/FigS2_methodcompar.png", method_p, nrow = 1, ncol = 1)


# export as "FigS2_method.png" # 630 by 372

#   # Diff Plot #######################
# char_diff <- char_comparison %>% 
#   pivot_wider(names_from = type, values_from = mgC_g)
# 
#  char_diff$diff <- char_diff$kmd - char_diff$sieved
# 
#  char_diff$abs_diff <- abs(char_diff$diff)
# 
# # pulling in total C measurements
# costech <- read.csv(here("data/costech_results.csv"))
# total <- costech %>%
#   filter(type == "raw")
# 
# order <- char_diff$sample_id
# 
# total <- total %>%
#   arrange(sapply(Sample_id, function(y) which(y == order)))
# 
# char_diff$total_per <- total$C_percent
# 
# # adding kmd percent in
# kmd <- costech %>%
#   filter(type == "kmd")
# 
# kmd <- kmd %>%
#   arrange(sapply(Sample_id, function(y) which(y == order)))
# 
# char_diff$kmd_per <- kmd$C_percent
# 
# # finding percent for sieved samples
# sieve <- read.csv(here("data/char_mass_sieve.csv"))
# 
# sieve$sieve_per <- (sieve$kmd_dry_weight / sieve$total_mass) * 100
# 
# sieve$sieve_per[sieve$sieve_per == "Inf"] <- 0
# 
# sieve <- sieve %>%
#   arrange(sapply(Sample_id, function(y) which(y == order)))
# 
# char_diff$sieve_per <- sieve$sieve_per
# 
# char_diff$abs_diff_per <- abs(char_diff$kmd_per - char_diff$sieve_per)
# 
# ## Modeling ##########################
# 
# model <- lm(abs_diff_per ~ total_per, data = char_diff)
# plot(model)
# 
# ggplot(char_diff, aes(x = total_per, y = abs_diff_per)) + 
#   geom_jitter(shape = 1) +
#   geom_smooth(method = "lm", col = "black") + 
#   background_grid() + panel_border() + 
#   labs(x = "Total Soil Carbon (%)", y = "Abs. Diff. in estimates (%)", 
#        title = "Absolute Differences in PyC estimates") +
#  ylim(-2.5e+07, 9e+07)
# 
# char_diff %>%
#   filter(total_per < 20) %>%
#   ggplot(aes(x = total_per, y = abs_diff_per)) + 
#   geom_jitter(shape = 1) +
#   geom_smooth(method = "lm", col = "black") + 
#   background_grid() + panel_border() + 
#   labs(x = "Total Soil Carbon (%)", y = "Abs. Diff. in estimates (%)", 
#        title = "Absolute Differences in PyC estimates") +
#   ylim(-2.5e+07, 9e+07)
# 
# diffplot
# 
# char_diff %>%
#   filter(total_per <20) %>%
#   ggplot(aes(x = total_per, y = abs_diff)) + 
#   geom_jitter(shape = 1) +
#   geom_smooth(method = "lm", col = "black") + 
#   background_grid() + panel_border() + 
#   labs(x = "Total Soil Carbon (%)", y = "Difference in estimates (mg)", title = "Differences in PyC estimates") 
# 
# 
# plot_grid(depth, diffplot,
#           ncol = 2, nrow = 1,
#           rel_widths = c(1,1),
#           labels = c("A.", "B."))
# 
# # save 900 x 350
