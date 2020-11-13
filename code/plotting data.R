setwd('/Users/katherinehayes/Desktop/Thesis/Data/')
# plotting data
site_data <- read.csv("~/Desktop/Thesis/Data/site_data.csv")
depth <- site_data$Depth
age <- site_data$median.probability
calendar_dates <- site_data$calendar.age

# setting symbols for alluvial deposits
alluvial_index <- which(site_data$Site.code == "WORM_03")
alluvial <- site_data[alluvial_index,]
site_data <- site_data[-alluvial_index,]

# age depth plot
plot(x = depth, y = age, main = "Age-depth Plot",xlab = "Depth (cm)", ylab = "Age in Calender Years")
points(x = alluvial$Depth, y = alluvial$median.probability)
# age against elevation
plot(x = site_data$ELEVATION, y = site_data$median.probability,
     main = "Age-Elevation", xlab = "Elevation (m)", ylab = "Age in Calender Years")
  points(x = alluvial$ELEVATION, alluvial$median.probability, pch = 23)

# histogram of dates
hist(x =age, breaks = 14,
     xlab = "Age in Calender Years", main = "Radiocarbon dates" )
  # code for plot without labels 
  # hist(x =age, breaks = 14, xlab = " ", ylab = " ", main = " " )

#age vs aspect
aspect <- site_data$ASPECT
plot(x = aspect, y = age,
     main = "Age vs Aspect", xlab = "Aspect (degrees)", ylab = "Age (Calender)")


# calender of events
norman_jennings <- matrix(c(1764, 1766, 1808, 1834, 1850, 1873, 1883, 1917, 1936), nrow = 9, ncol = 1)
plot(x = site_data$corrected.error, y = calendar_dates, xlab = 'Index', ylab = 'Years')

points(norman_jennings, pch = 19)
total_plot <- list("soil charcoal" = calendar_dates, "tree rings" = norman_jennings)
stripchart(total_plot, xlab = "Calender years", ylab = "Index", method = 'jitter', col= c("black", "red"), pch = 1)
points(norman_jennings, pch = 19)
myhist <- hist(calendar_dates)
stripchart(calendar_dates, pch = 1, method = 'jitter', ylab = "Index of soil charcoal", xlab = "Calendar years")
