# grams / meter 2
setwd("Desktop/Thesis/Data/")
install.packages("reshape2")
library(reshape2)

gm2 <- read.csv("gm2all.csv")

# indexing the data
rms <- gm2[which(gm2$site_type == "ridgetop mineral soil"),]
hms <- gm2[which(gm2$site_type == "hillslope mineral soil"),]
vms <- gm2[which(gm2$site_type == "valley mineral soil"),]

# AVERAGING BY DEPTH
  site_averages <- matrix(data = NA, ncol = 3, nrow = 21)
  site_averages[,2] <- rep(c("A", "B", "C", "D", "E", "F", "G"))
  # ridgetop
    site_averages[1:7,3] <- tapply(rms$PyC.g.m2, INDEX = rms$Depth, mean) 
    site_averages[1:7,1] <- rep("ridgetop")
  # valley
    site_averages[8:14,3] <- vms$PyC.g.m2
    site_averages[8:14,1] <- rep("valley")
  # hillslope
    site_averages[15:21,3] <- tapply(hms$PyC.g.m2, INDEX = hms$Depth, mean)
    site_averages[15:21, 1] <- rep("hillslope")  

  # ggplot(data = gm2, aes(x= gm2$Depth, y = gm2$PyC.g.m2, color = gm2$site)) + geom_point() +
    scale_color_manual(values = c("#202020", "#E69F00", "#56B4E9"),
                       name = "Site Type:",
                       labels = c("Hillslope Mineral Soil", "Ridgetop Mineral Soil", "Valley Mineral Soil")) +
    background_grid() + panel_border()
  
  # converting data
    site_averages <- as.data.frame(site_averages)
    colnames(site_averages) <- c("site_type", "depth", "pyc_mass")
    site_averages$pyc_mass <- as.numeric(as.character(site_averages$pyc_mass))
  
  # plotting data
    char_mass_ggplot <- ggplot(data = site_averages, 
           aes(x = site_averages$depth, y = site_averages$pyc_mass, 
               color = site_averages$site_type, group = site_averages$site_type)) + 
      scale_color_manual(values = c("#202020", "#E69F00", "#56B4E9"),
                         name = "Site Type:",
                         labels = c("Hillslope Mineral Soil", "Ridgetop Mineral Soil", "Valley Mineral Soil")) +
      geom_point() + geom_line() +
      background_grid() + panel_border() + 
      labs(x = "Depth (cm)", y = "Average Mass of PyC (g/m2)", title = "Mass of PyC across Site Types") + 
      scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35"))
    char_mass_ggplot
    save_plot("char_mass.png", char_mass_ggplot, base_aspect_ratio = 1.8)
    
    # ggplot(data = gm2, aes(x = gm2$Depth, y = gm2$PyC.g.m2, color = gm2$site_type)) +
    geom_boxplot()
    
# AVERAGING BY SITE
site_group_averages <- matrix(data = NA, ncol = 3, nrow = 35)
site_group_averages[,2] <- rep(c("A", "B", "C", "D", "E", "F", "G"))
  # EELS
  eels <- gm2[which(gm2$site.group == "EELS"),]
  site_group_averages[1:7,3] <- tapply(eels$PyC.g.m2, INDEX = eels$Depth, mean) 
  site_group_averages[1:7,1] <- rep("eels")
  # WORM TRAIL
  worm <- gm2[which(gm2$site.group == "WORM"),]
  site_group_averages[8:14,3] <- tapply(worm$PyC.g.m2, INDEX = worm$Depth, mean)
  site_group_averages[8:14,1] <- rep("worm")
  # RIDGETOP
  ridg <- gm2[which(gm2$site.group == "RIDG"),]
  site_group_averages[15:21,3] <- tapply(ridg$PyC.g.m2, INDEX = ridg$Depth, mean)
  site_group_averages[15:21, 1] <- rep("ridg")  
  # SALM
  salm <- gm2[which(gm2$site.group == "SALM"),]
  site_group_averages[22:28,3] <- tapply(salm$PyC.g.m2, INDEX = salm$Depth, mean)
  site_group_averages[22:28,1] <- rep("salm")  
  # GOVERNER'S GROVE
  gov <- gm2[which(gm2$site.group == "GOV"),]
  site_group_averages[29:35,3] <- tapply(gov$PyC.g.m2, INDEX = gov$Depth, mean)
  site_group_averages[29:35,1] <- rep("gov")  

  # converting data
  site_group_averages <- as.data.frame(site_group_averages)
  colnames(site_group_averages) <- c("site_group", "depth", "pyc_mass")
  site_group_averages$pyc_mass <- as.numeric(as.character(site_group_averages$pyc_mass))
  
  ggplot(site_group_averages, aes(site_group_averages$depth, site_group_averages$pyc_mass, 
                                  color = site_group_averages$site_group, group = site_group_averages$site_group)) + geom_line() + 
    scale_color_manual(name = "Site",
                       labels = c("Elk River", "Governor's Grove", "Ridge Trail", "Salmon Creek Trail", "Worm Trail")) +
    background_grid() + panel_border() +
    labs(x = "Depth (cm)", y = "Average Mass of PyC (g/m2)", title = "Mass of PyC across Sites") + 
    scale_x_discrete(labels = c("0-5", "5-10", "10-15", "15-20", "20-25", "25-30", "30-35"))
  
  
# grams per meter2 per site attribute data
site_attributes <- read.csv("char_sites.csv")
site_attributes <- site_attributes[which(site_attributes$soil == "soil"),]
site_means <- matrix(data = NA, nrow = 17, ncol = 2)
site_means[,1] <- c("EELS_01", "GOG_01","GOG_02","RIDG_01","RIDG_02","SALM_01","SALM_02", "SALM_03", "WOLF_01", "WOLF_02", "WOLF_03",
                    "WOLF_04", "WORF_01", "WORF_02", "WORF_03", "WORF_04", "WORF_05")
site_means[,2] <- tapply(gm2$PyC.g.m2, gm2$Site, mean)
site_means <- as.data.frame(site_means)
colnames(site_means) <- c("site", "pyc")
site_attributes <- merge(site_means, site_attributes, by= "site")

site_attributes$pyc <- as.numeric(as.character(site_attributes$pyc))

ggplot(site_attributes, aes(site_attributes$elevation, site_attributes$pyc)) + geom_point() +
  geom_smooth(method = "lm")

ggplot(site_attributes, aes(site_attributes$slope, site_attributes$pyc)) + geom_point() +
  geom_smooth(method = "lm")

ggplot(site_attributes, aes(site_attributes$aspect..ccw.from.E., site_attributes$pyc)) + geom_point() +
  geom_smooth(method = "lm")

ggplot(site_attributes, aes(site_attributes$topidx, site_attributes$pyc)) + geom_point() +
  geom_smooth(method = "lm")

ggplot(site_attributes, aes(site_attributes$sun, site_attributes$pyc)) + geom_point() +
  geom_smooth(method = "lm")

