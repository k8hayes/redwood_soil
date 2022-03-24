# Example code for calibrating a radiocarbon date using the Bchron package.
install.packages("Bchron")
library("Bchron")  #load the package
?BchronCalibrate  #see the help page for the function

# Radiocarbon dates of soil charcoal from Vancouver Island
# http://esapubs.org/archive/ecol/E084/004/appendix-B.htm

# read in an array of 119 dates, an array of standard deviations for those dates, an array of sample ID codes, and an array of depth of charcoal in soil.
cq_dates <- c(840,4280,5460,7690,2980,4920,7320,2360,1200,990,2780,2690,1370,1150,2400,2360,2390,2360,8780,1140,1060,9210,430,410,1060,1590,1120,9410,9670,1080,1060,910,1020,3600,1970,2950,5730,1410,2220,8190,1630,4150,1290,1420,2920,5310,860,9030,1210,4060,4150,2590,6170,500,3070,1300,1120,1340,2790,4550,980,2710,4330,3050,3470,450,3190,960,3420,6900,3880,3860,850,9560,10030,440,8690,3250,8460,6570,7180,4750,4900,2400,10240,4680,640,8190,8150,9180,8710,390,3110,600,8340,8280,400,8120,9440,9120,9210,520,750,270,8320,350,420,350,5860,480,1033,8890,8300,9130,8640,460,430,9560,5910)
cq_sds <- c(60,50,60,50,60,40,50,50,50,50,40,50,60,50,60,70,60,80,60,50,50,50,60,40,50,60,60,50,70,50,50,70,50,70,50,60,60,50,60,60,70,60,70,50,50,50,60,50,50,50,50,50,40,50,50,50,50,50,50,50,50,50,50,70,50,40,50,70,40,60,60,60,50,50,50,40,60,50,60,50,50,50,50,50,50,50,50,50,50,50,50,40,60,90,50,50,50,90,70,70,50,50,50,50,50,40,50,40,50,50,50,90,50,60,50,70,50,60,40)
cq_ids <- c("LE06ChO","LE06ChB1","LE06ChB2","LE03G","LE02hmid","LE02hbottom","LE61A","LE07AhB","PR08AhA","PR08AhB1","LE60A","PR07BhB","LW01BhB2","LW01BhB4","MR1h3-4A","MR1h4-5A","MR1h13-14","MR1h14-15","TA82ChB1","LW60ChB1","LW60ChB2","TA81ChB2","PR06AhB1","PR06AhB2","PR06AhB3","PR06AhB4","LW06C","TA03C","TA03BhB2","CR1h15-16","CR1h17-18","CR1h19-20","CR1h24-26","CR1h27-28","UE01A","UE03D","UE03C","LW50B","URE17ChB1","URE17ChB2","LU1","LU1A","LU2B","LU2C","URE56BhB","URE56AhB","URE55ChB3","URE55BhB3","URW53AhB","TA02BhB2","TA02BhB3","URE57BhB3","URW82B","URW02BhB","URW02C","URW80A","URW63BhB2","URW63BhB3","URE54BhO1","URE54BhB1","URW62D","URE52A","URE52B","URE16C","URE16A","URE51EhAE1","URE15D","URW60A","URW03A","URE14ChB1","URE14ChB2","URE14ChB3","URW52A","URE50ChB2","URE50BhB2","URW65A","URE61ChB2","URE61ChB4","URE61ChB5","URE65A","URE65C","URW06BhB","URW06C","URE62C","URE62A","URW66AhB2","URW67A","URW01BhB1","URW01BhB3","URE07BhB2","URE07BhB3","URW07BhA1","URW07BhA3","URE67AhO","URE67AhB3","URE67AhB5","URE68A","URE66BhB","URE66ChB","URW08ChB3","URW08ChB4","RT60ChO","RT60BhB2","RT50A","RT05AhB","RT51hO3","RT51hO4","RT51hA1","RT51hA4","RT53ChB2","RT12AhB2","RT55AhB3","RT57AhO1","RT57AhB2","RT57AhB4","RT54C","RT81A","RT07BhB1","RT07ChB4")
cq_depths <- c(3,13,17,20,35,40,5,13,7,12,5,12,15,30,3,4,13,14,15,5,9,11,6,11,17,22,10,15,23,15,17,19,24,27,4,5,5,13,11,17,12,10,10,15,5,5,13,21,8,20,33,7,8,9,10,4,5,7,2,9,5,3,3,8,6,7,4,6,8,8,13,16,4,8,14,3,5,9,11,12,10,13,12,7,7,10,3,13,27,18,27,9,17,2,8,12,2,13,6,12,16,3,9,10,15,7,9,11,17,14,17,10,2,10,14,5,8,13,33)

# Calibrate the dates, results are listed in object cq_out
cq_out <- BchronCalibrate(ages=cq_dates,ageSds=cq_sds,ids=cq_ids,calCurves=rep("intcal13",119),positions=cq_depths)

# The calibrated age for the first age in the list (840 +/- 60) is located here:
age1 <- cq_out[[1]]$ageGrid
density1 <- cq_out[[1]]$densities
plot(age1,density1,type="l")

#or plot each date one at a time (this seems to crash after 10 plots).
plot(cq_out,pause=TRUE)

# create a plot of calibrated ages by depth in soil
plot(cq_out,withPositions=TRUE,dateHeight=4,borderCol="black")

# create a histogram of the summed calibrated radiocarbon date distirbutions
# first sample the dates using a large number of samples (1000 samples per date).
s <- SampleAges(cq_out,n_samp=1000)
max(s)  #the highest sample age is near 12,400 BP

#then plot the histogram, in 100-year bins
hist(s,breaks=seq(0,12400,100),freq=FALSE)

# A more sophisticated way to sum many radiocarbon dates to obtain a mean intensity chronology:
# BchronDensity fits a Gaussian Mixture Model that is a list a 'normal' Gaussian curves that sum
# together to represent the number of radiocarbon ages over time, without displaying minor
# variations that are the result of the calibration process.

cq_density <- BchronDensity(ages=cq_dates,ageSds=cq_sds,calCurves=rep("intcal13",119))

#see ?plot.BchronDensityRun for details on plotting options.  The red line is the summed raw calibrated dates.
plot(cq_density,plotDates=FALSE,plotRawSum=TRUE)

