# Kate 10/23
# need to convert site coordinates from lat/long into decimal degrees in order to plot correctly in arcmap
# got functions from stackoverflow
# install.packages("measurements")
getwd()
  site_locations <- read.csv(file = "site locations.csv")
# change degree symbol to a space
site_locations$Latitude = gsub('°', ' ', site_locations$Latitude)
site_locations$Longitude = gsub('°', ' ', site_locations$Longitude)


# convert from decimal minutes to decimal degrees
site_locations$Latitude = measurements::conv_unit(site_locations$Latitude, from = 'deg_dec_min', to = 'dec_deg')
site_locations$Longitude = measurements::conv_unit(site_locations$Longitude, from = 'deg_dec_min', to = 'dec_deg')
