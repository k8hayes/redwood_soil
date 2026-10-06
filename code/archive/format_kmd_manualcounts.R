# comparing kmd to counting

library(here)
library(tidyverse)
library(cowplot)
theme_set(theme_cowplot())

manual <- read.csv(here('data/char_mass_sieve.csv'))
costech_char <- read.csv(here('data/costech_results.csv'))

# Manual counting  ##############################
# clean up
  # fixing column names
    names(manual)
    names(manual) <- c("site_id", "depth_category", "depth", "dry_weight", "mass_2", "mass_0.5", "total_mass", "total_mass_mg", "MgC_g")
  # changing NAs to zero
    manual$mass_2[which(is.na(manual$mass_2))] <- 0
    manual$mass_0.5[which(is.na(manual$mass_0.5))] <- 0
  # calculating total mass (mg)
    manual$total_mass_mg <- (manual$mass_2 + manual$mass_0.5)*1000
  # calculating concentration
    manual$char_concentration <- manual$total_mass_mg/manual$dry_weight
  # changing InF to NA
    manual$char_concentration[which(manual$char_concentration == "Inf")] <- 0
    manual$char_concentration[which(is.na(manual$char_concentration))] <- 0

# KMD counting ##################################
    names(costech_char)
    colnames(costech_char) <- c("site", "site_id", "sample_id", "depth_category", "kmd_starting_weight", "digested_weight", "tin_weight", "costech_sample_weight", "tray_placement", "C_percent", "N_percent", "Del_c", "Del_N", "mg.carbon", "tray_number","type")

    # pulling out just digested charcoal
      kmd <- costech_char[which(costech_char$type == "kmd"),]
      kmd$kmd_char_concentration <-(((kmd$C_percent*kmd$digested_weight)/kmd$kmd_starting_weight)*1000)/100
      View(kmd)

ggplot(kmd, aes(x = site, y = C_percent)) + geom_point()
