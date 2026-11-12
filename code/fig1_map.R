## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## Fig. 1 - Site map on lidar hillshade, with California locator
## --------------------------------------------------------------- ##
# Run after 00_load-lib.R. Writes output/figures/Fig1_site_map.png
#
# Inputs (see data/README.md for where each comes from):
#   data/raw/sites.csv
#   data/raw/gis/redwood_range_little.geojson      coast redwood range
#   data/raw/gis/headwaters_forest_reserve.geojson reserve boundary;
#                                                  downloaded from BLM on
#                                                  the first run
#   data/raw/gis/dem_1m/*.tif                      USGS 1 m elevation tiles;
#                                                  downloaded by hand, not
#                                                  kept in git
#
# The hillshade is saved to data/processed/hillshade_reserve.tif, so the
# large elevation tiles are only needed the first time.

# Parameters ###############################
map_buffer_m       <- 500   # margin around the reserve and sites
hillshade_cell_m   <- 4     # 1 m elevation is averaged to this cell size
sun_elevation_deg  <- 45
sun_direction_deg  <- 315   # light from the north-west
scale_bar_km       <- 1

reserve_path   <- here::here("data/raw/gis/headwaters_forest_reserve.geojson")
range_path     <- here::here("data/raw/gis/redwood_range_little.geojson")
dem_folder     <- here::here("data/raw/gis/dem_1m")
hillshade_path <- here::here("data/processed/hillshade_reserve.tif")

map_crs <- "EPSG:26910"   # NAD83 / UTM zone 10N, the CRS of the elevation tiles

# Where surveys overlap, earlier names in this list win.
survey_priority <- c("NoCAL_Wildfires_B4_2018", "NorthernCA_B22",
                     "Supp_Funding_2018_D18")

reserve_url <- paste0(
  "https://gis.blm.gov/arcgis/rest/services/lands/BLM_Natl_NLCS_NM_NCA/",
  "MapServer/0/query?where=NCA_NAME%20LIKE%20%27%25Headwaters%25%27",
  "&outFields=*&outSR=4326&f=geojson")

site_labels <- c("alluvial fan"           = "Alluvial fan",
                 "colluvial hollow"       = "Colluvial hollow",
                 "hillslope mineral soil" = "Hillslope mineral soil",
                 "ridgetop mineral soil"  = "Ridgetop mineral soil",
                 "valley mineral soil"    = "Valley mineral soil")
site_colours <- c("alluvial fan"           = "#543005",
                  "colluvial hollow"       = "#bf812d",
                  "hillslope mineral soil" = "#c7eae5",
                  "ridgetop mineral soil"  = "#35978f",
                  "valley mineral soil"    = "#003c30")
site_shapes <- c("alluvial fan"           = 23,
                 "colluvial hollow"       = 21,
                 "hillslope mineral soil" = 24,
                 "ridgetop mineral soil"  = 24,
                 "valley mineral soil"    = 24)

range_green   <- "#74c476"
reserve_green <- "#00441b"

# Reserve boundary ###############################
if (!file.exists(reserve_path)) {
  message("Downloading the reserve boundary from BLM ...")
  reserve_download <- tryCatch(sf::st_read(reserve_url, quiet = TRUE),
                               error = function(e) NULL)
  if (is.null(reserve_download) || nrow(reserve_download) == 0) {
    stop("Could not download the Headwaters Forest Reserve boundary.\n",
         "Download the 'BLM Natl NLCS National Monuments National ",
         "Conservation Areas Polygons' layer by hand, keep the Headwaters ",
         "polygon, and save it as\n  ", reserve_path)
  }
  sf::st_write(reserve_download, reserve_path, quiet = TRUE)
}
reserve <- sf::st_read(reserve_path, quiet = TRUE)
message("Reserve boundary: ", nrow(reserve), " polygon(s)")

# Sites ###############################
sites <- read.csv(here::here("data/raw/sites.csv"), stringsAsFactors = FALSE)
sites <- sites[sites$dated | sites$cored, ]
sites <- sf::st_as_sf(sites, coords = c("longitude", "latitude"), crs = 4326)
message("Sites on the map: ", nrow(sites))

# Hillshade ###############################
if (!file.exists(hillshade_path)) {
  dem_files <- list.files(dem_folder, pattern = "\\.tif$", full.names = TRUE)
  if (length(dem_files) == 0) {
    stop("No elevation tiles found in ", dem_folder,
         "\nSee data/README.md for how to download them.")
  }

  # Map extent: the reserve and all sites, plus a margin
  map_box <- sf::st_bbox(c(sf::st_geometry(sf::st_transform(reserve, map_crs)),
                           sf::st_geometry(sf::st_transform(sites, map_crs))))
  template <- terra::rast(xmin = floor(map_box[["xmin"]] - map_buffer_m),
                          xmax = ceiling(map_box[["xmax"]] + map_buffer_m),
                          ymin = floor(map_box[["ymin"]] - map_buffer_m),
                          ymax = ceiling(map_box[["ymax"]] + map_buffer_m),
                          resolution = hillshade_cell_m, crs = map_crs)

  # Tiles from different surveys overlap. They are added in the order of
  # survey_priority, and a later tile only fills cells that are still empty.
  survey_rank <- sapply(basename(dem_files), function(file_name) {
    rank <- which(sapply(survey_priority, grepl, x = file_name, fixed = TRUE))
    if (length(rank) == 0) length(survey_priority) + 1 else rank[1]
  })
  dem_files <- dem_files[order(survey_rank)]

  dem <- NULL
  for (dem_file in dem_files) {
    tile <- terra::rast(dem_file)
    stopifnot(terra::same.crs(tile, template))
    overlap <- terra::intersect(terra::ext(tile), terra::ext(template))
    if (is.null(overlap)) next
    piece <- terra::resample(terra::crop(tile, overlap), template,
                             method = "average")
    if (all(is.na(terra::minmax(piece)))) next
    message("Using ", basename(dem_file))
    dem <- if (is.null(dem)) piece else terra::cover(dem, piece)
  }
  if (is.null(dem)) stop("None of the elevation tiles covers the map area.")

  empty_share <- terra::global(is.na(dem), "mean")[1, 1]
  message("Map area without elevation data: ", round(100 * empty_share, 1), "%")

  slope  <- terra::terrain(dem, "slope", unit = "radians")
  aspect <- terra::terrain(dem, "aspect", unit = "radians")
  hillshade <- terra::shade(slope, aspect, angle = sun_elevation_deg,
                            direction = sun_direction_deg)

  dir.create(dirname(hillshade_path), showWarnings = FALSE)
  terra::writeRaster(hillshade, hillshade_path, overwrite = TRUE)
}
hillshade <- terra::rast(hillshade_path)

# Hillshade as a matrix of greys, drawn as a background image so that the
# fill scale stays free for the site symbols.
shade_values <- terra::as.matrix(hillshade, wide = TRUE)
shade_range  <- range(shade_values, na.rm = TRUE)
shade_scaled <- (shade_values - shade_range[1]) / diff(shade_range)
shade_scaled[is.na(shade_scaled)] <- 1   # cells with no data are drawn light
shade_greys  <- matrix(grey(0.05 + 0.9 * shade_scaled), nrow = nrow(shade_scaled))

reserve_map <- sf::st_transform(reserve, map_crs)
sites_map   <- sf::st_transform(sites, map_crs)

# Scale bar position: lower left corner of the map
map_limits <- as.vector(terra::ext(hillshade))  # xmin, xmax, ymin, ymax
bar_x <- map_limits[1] + 0.04 * (map_limits[2] - map_limits[1])
bar_y <- map_limits[3] + 0.05 * (map_limits[4] - map_limits[3])
bar_length_m <- scale_bar_km * 1000

# Main panel ###############################
site_map <- ggplot() +
  annotation_raster(shade_greys, xmin = map_limits[1], xmax = map_limits[2],
                    ymin = map_limits[3], ymax = map_limits[4]) +
  geom_sf(data = reserve_map, fill = NA, colour = reserve_green,
          linewidth = 0.8) +
  geom_sf(data = sites_map,
          aes(shape = site_type, fill = site_type), colour = "black",
          size = 3, stroke = 0.4) +
  scale_fill_manual(values = site_colours, labels = site_labels) +
  scale_shape_manual(values = site_shapes, labels = site_labels) +
  annotate("segment", x = bar_x, xend = bar_x + bar_length_m,
           y = bar_y, yend = bar_y, linewidth = 1.2, colour = "white") +
  annotate("text", x = bar_x + bar_length_m / 2, y = bar_y,
           label = paste(scale_bar_km, "km"), vjust = -0.8, colour = "white") +
  coord_sf(crs = map_crs, datum = sf::st_crs(4326), expand = FALSE,
           xlim = map_limits[1:2], ylim = map_limits[3:4]) +
  labs(x = NULL, y = NULL, fill = NULL, shape = NULL) +
  guides(fill = guide_legend(nrow = 2), shape = guide_legend(nrow = 2)) +
  theme(legend.position = "bottom",
        panel.border = element_rect(colour = "black", fill = NA))

# California locator ###############################
california <- sf::st_as_sf(maps::map("state", "california", plot = FALSE,
                                     fill = TRUE))
redwood_range <- sf::st_read(range_path, quiet = TRUE)
if (is.na(sf::st_crs(redwood_range))) sf::st_crs(redwood_range) <- 4267  # NAD27
redwood_range <- sf::st_transform(redwood_range, 4326)
reserve_point <- sf::st_centroid(sf::st_union(sf::st_transform(reserve, 4326)))

locator_map <- ggplot() +
  geom_sf(data = california, fill = "grey92", colour = "grey40") +
  geom_sf(data = redwood_range, fill = range_green, colour = NA) +
  geom_sf(data = reserve_point, shape = 22, size = 3, stroke = 1.2,
          colour = reserve_green, fill = NA) +
  coord_sf(crs = 3310) +   # California Albers
  theme_void()

# Combine and save ###############################
fig1 <- plot_grid(locator_map, site_map, nrow = 1, rel_widths = c(1, 4))

dir.create(here::here("output/figures"), recursive = TRUE, showWarnings = FALSE)
save_plot(here::here("output/figures/Fig1_site_map.png"), fig1,
          base_width = 11, base_height = 6.5, bg = "white")
