## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 04 - Carbon concentrations and stocks
## --------------------------------------------------------------- ##
# Computes total and pyrogenic carbon for every core sample and sums
# them to site stocks for the top 30 cm. Writes:
#   data/processed/carbon_by_sample.csv        one row per site x ring
#   data/processed/carbon_stocks_by_site.csv   one row per site
#   output/tables/carbon_by_depth.csv          means per depth increment
#   output/tables/carbon_stock_summary.csv     numbers quoted in the text
#
# Requires the here package (called with here::).

# Parameters ###############################
rings_used       <- c("A", "B", "C", "D", "E", "F")  # 0-30 cm; G is dropped
core_diameter_cm <- 5
ring_height_cm   <- 5

# Each sample was dried in two parts: a small subsample (August 2017) and
# the rest of the sample (October-December 2017). TRUE adds the two.
# FALSE reproduces the earlier calculations, which used the rest only.
add_subsample_mass <- TRUE

core_area_cm2 <- pi * (core_diameter_cm / 2)^2

# Output folders are created if they do not exist yet.
dir.create(here::here("data/processed"), showWarnings = FALSE)
dir.create(here::here("output/tables"), recursive = TRUE, showWarnings = FALSE)

# Elemental results ###############################
# type "raw" = undigested soil, type "kmd" = residue after acid-peroxide
# digestion. Duplicate runs and standards are not used here.
elemental <- read.csv(here::here("data/raw/elemental_results.csv"),
                      stringsAsFactors = FALSE)
elemental <- elemental[elemental$depth_category %in% rings_used, ]

undigested <- elemental[elemental$type == "raw",
                        c("site_name", "depth_category", "site_type",
                          "C_percent")]
names(undigested) <- c("site_id", "ring", "site_type", "total_c_percent")

digested <- elemental[elemental$type == "kmd",
                      c("site_name", "depth_category", "C_percent",
                        "starting_weight", "digested_weight")]
names(digested) <- c("site_id", "ring", "residue_c_percent",
                     "mass_before_digestion_g", "mass_after_digestion_g")

carbon <- merge(undigested, digested, by = c("site_id", "ring"))
stopifnot(nrow(carbon) == nrow(undigested), nrow(carbon) == nrow(digested))

# Concentrations in mg C per g dry soil. Pyrogenic C is the carbon left
# in the residue, scaled by the fraction of soil mass that survived.
carbon$total_c_mg_g <- carbon$total_c_percent * 10
carbon$pyc_mg_g <- carbon$residue_c_percent * 10 *
  carbon$mass_after_digestion_g / carbon$mass_before_digestion_g
carbon$pyc_fraction <- carbon$pyc_mg_g / carbon$total_c_mg_g

# Dry mass of each core sample ###############################
core_mass <- read.csv(here::here("data/raw/core_dry_mass.csv"),
                      stringsAsFactors = FALSE)
core_mass <- core_mass[core_mass$ring %in% rings_used, ]

if (add_subsample_mass) {
  # A sample with no main mass was used up by the subsample, so the
  # subsample is the whole sample. A missing subsample mass counts as zero.
  main_g      <- ifelse(is.na(core_mass$main_dry_mass_g), 0,
                        core_mass$main_dry_mass_g)
  subsample_g <- ifelse(is.na(core_mass$subsample_dry_mass_g), 0,
                        core_mass$subsample_dry_mass_g)
  core_mass$dry_mass_g <- main_g + subsample_g
  core_mass$dry_mass_g[is.na(core_mass$main_dry_mass_g) &
                         is.na(core_mass$subsample_dry_mass_g)] <- NA
} else {
  core_mass$dry_mass_g <- core_mass$main_dry_mass_g
}

carbon <- merge(carbon,
                core_mass[, c("site_id", "ring", "depth_top_cm",
                              "depth_bottom_cm", "dry_mass_g")],
                by = c("site_id", "ring"))
stopifnot(nrow(carbon) == nrow(undigested))

message("Samples: ", nrow(carbon), " from ", length(unique(carbon$site_id)),
        " sites")
message("Samples with no dry mass: ", sum(is.na(carbon$dry_mass_g)))

# Stocks per sample ###############################
# Stock (g C per m2) = concentration x dry mass / core area.
# Bulk density assumes a full ring, so it is too low wherever the ring
# was only partly filled (mostly ring A).
grams_per_m2 <- function(concentration_mg_g, dry_mass_g) {
  concentration_mg_g / 1000 * dry_mass_g / core_area_cm2 * 10000
}

carbon$bulk_density_g_cm3 <- carbon$dry_mass_g / (core_area_cm2 * ring_height_cm)
carbon$total_c_g_m2 <- grams_per_m2(carbon$total_c_mg_g, carbon$dry_mass_g)
carbon$pyc_g_m2     <- grams_per_m2(carbon$pyc_mg_g, carbon$dry_mass_g)

carbon <- carbon[order(carbon$site_id, carbon$depth_top_cm), ]
write.csv(carbon, here::here("data/processed/carbon_by_sample.csv"),
          row.names = FALSE)

# Stocks per site ###############################
# A site with any missing sample mass gets NA, not a partial sum.
site_stocks <- aggregate(cbind(total_c_g_m2, pyc_g_m2) ~ site_id + site_type,
                         data = carbon, FUN = sum, na.action = na.pass)
site_stocks$pyc_share_of_total_c <- site_stocks$pyc_g_m2 / site_stocks$total_c_g_m2
site_stocks$pyc_kg_ha <- site_stocks$pyc_g_m2 * 10

write.csv(site_stocks, here::here("data/processed/carbon_stocks_by_site.csv"),
          row.names = FALSE)

# Means per depth increment ###############################
by_depth <- aggregate(cbind(total_c_mg_g, pyc_mg_g, pyc_fraction,
                            bulk_density_g_cm3) ~ depth_top_cm + depth_bottom_cm,
                      data = carbon, FUN = mean, na.action = na.pass,
                      na.rm = TRUE)
by_depth$n_samples <- as.vector(table(carbon$depth_top_cm))
by_depth <- by_depth[order(by_depth$depth_top_cm), ]

write.csv(by_depth, here::here("output/tables/carbon_by_depth.csv"),
          row.names = FALSE)

# Summary across sites ###############################
summarise_sites <- function(values, quantity, unit) {
  data.frame(quantity = quantity, unit = unit,
             n_sites = sum(!is.na(values)),
             mean = mean(values, na.rm = TRUE),
             sd = sd(values, na.rm = TRUE),
             min = min(values, na.rm = TRUE),
             max = max(values, na.rm = TRUE))
}

stock_summary <- rbind(
  summarise_sites(site_stocks$pyc_g_m2, "pyrogenic C stock, 0-30 cm", "g/m2"),
  summarise_sites(site_stocks$total_c_g_m2, "total C stock, 0-30 cm", "g/m2"),
  summarise_sites(site_stocks$pyc_kg_ha, "pyrogenic C stock, 0-30 cm", "kg/ha"),
  summarise_sites(site_stocks$pyc_share_of_total_c * 100,
                  "pyrogenic share of total C stock", "percent")
)
stock_summary$subsample_mass_added <- add_subsample_mass

write.csv(stock_summary, here::here("output/tables/carbon_stock_summary.csv"),
          row.names = FALSE)

print(stock_summary, digits = 4)
