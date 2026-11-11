
library(ggmap)
library(ggplot2)
library(maps)
library(mapdata)

points <- read.csv("Google Drive/Projects/Redwoods C/Master's/char_sites.csv")

sbbox <- make_bbox(lat = y,lon = x, data = points)
sbbox[4] <- 40.645
sbbox[2] <- 40.61
sbbox[1] <- -124.09
sbbox[3] <- -124.02

# First get the map. By default it gets it from Google.  I want it to be a satellite map
sq_map <- get_map(location = sbbox, maptype = "satellite", source = "google")

# converting bounding box to center/zoom specification. (experimental)
# Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=34.75309,-119.751995&zoom=16&size=640x640&scale=2&maptype=satellite&language=en-EN&sensor=false

ggmap(sq_map) + geom_point(data = points, mapping = aes(x = x, y = y), color = "red")
#> Warning: Removed 3 rows containing missing values (geom_point).

valley <- points[points$site.type == "valley mineral soil",]
ridge <- points[points$site.type == "ridgetop mineral soil",]
hillslope <- points[points$site.type == "hillslope mineral soil",]
colluvial <- points[points$site.type == "colluvial hollow",]
alluvial <- points[points$site.type == "alluvial fan",]
  
sq_map3 <- get_map(location = sbbox,  maptype = "satellite", source = "google", zoom = 13)

ggmap(sq_map3) + 
  geom_point(data = valley, 
             mapping = aes(x = x, y = y),color = "#56B4E9", size = 5, pch = 24, fill = "#B1DAF4") +
  geom_point(data = ridge, 
             mapping = aes(x = x, y = y), color = "#E69F00", size = 5, pch = 22, fill = "#F3D095") +
  geom_point(data = hillslope, 
             mapping = aes(x = x, y = y), color = "#212121", size = 5, pch = 20, fill = "#9C9C9C") +
  geom_point(data = colluvial,
             mapping = aes(x = x, y = y), color = "#019E73", size = 5, pch = 20, fill = "#98D0BD") +
  geom_point(data = alluvial, 
             mapping = aes(x = x, y = y), color = "#D55E00", size = 5, pch = 22, fill = "#EBB494") +
  labs(x = "Longitude", y = "Latitude")


# head <- points[points$site == "EELS_01",]
# states <- map_data("state")
# ca_df <- subset(states, region == "california")
# ca_base <- ggplot(data = ca_df, mapping = aes(x = long, y = lat, group = group)) + 
#   coord_fixed(1.3) + 
#   geom_polygon(color = "black", fill = "white") 
# ca_base + theme_nothing() 
