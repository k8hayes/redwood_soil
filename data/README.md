# Data

## raw/

Inputs to the analysis. Code never writes here.

| File | Contents |
|---|---|
| `radiocarbon_dates.csv` | One row per radiocarbon date (43). CAMS number, site, depth, conventional age and error, F14C where a laboratory report is available, whether the date is used, and the source of each row. Modern dates have no conventional age. |
| `cams_reports/` | Laboratory reports from the Center for Accelerator Mass Spectrometry. The July 2017 report (CAMS 177453-177465) is missing. |
| `cams_submission_forms/` | Sample submission forms. |
| `charcoal_sample_inventory.xlsx` | Every charcoal piece collected from the soil pits, with depth and whether it was dated. |
| `elemental_results.csv` | Carbon and nitrogen results for every sample. `type` is `raw` (undigested soil), `kmd` (residue after acid-peroxide digestion), `dup` (duplicate run) or a standard. `depth_category` A-F are the 5 cm rings from 0 to 30 cm; G is the unringed bottom sample. |
| `elemental_results_lab_workbook.xlsx` | The workbook the elemental results came from. |
| `core_dry_mass.csv` | Dry mass of every core sample. `main_dry_mass_g` is the sample dried October-December 2017; `subsample_dry_mass_g` is the subsample dried August 2017. The `note` column records missing values and two corrections to the laboratory records. |
| `lab_workbook.xlsx` | Laboratory records (drying, grinding, digestion, sieving, counts). Source of `main_dry_mass_g`. |
| `lab_workbook_august_2017_subsamples.xlsx` | Earlier laboratory records. Source of `subsample_dry_mass_g`. |
| `sieved_charcoal_mass.csv` | Mass of charcoal sieved from the second core at each site, by size class. Its dry-weight and concentration columns are superseded by `core_dry_mass.csv` and the code. |
| `sites.csv` | One row per site: location, site type, coordinates, elevation, year sampled, and whether it was dated and cored. |
| `gis/redwood_range_little.geojson` | Natural range of coast redwood (*Sequoia sempervirens*) from Little's "Atlas of United States Trees", digitized by the USGS (NAD27). Copied from https://github.com/wpetry/USTreeAtlas. |
| `gis/headwaters_forest_reserve.geojson` | Reserve boundary from the BLM layer "NLCS National Monuments, National Conservation Areas and Similar Designations". Downloaded by `code/fig1_map.R` the first time it runs. |
| `gis/dem_1m/` | USGS 3DEP 1 m elevation tiles covering the reserve. Not kept in git (large). Download from the National Map downloader (https://apps.nationalmap.gov/downloader/): choose Elevation Products (3DEP), 1 meter DEM, draw a box around the reserve, and save the GeoTIFFs here. Only needed to rebuild `data/processed/hillshade_reserve.tif`. |
| `fire_scar_events.csv`, `fire_history_literature.xlsx` | Published and unpublished fire-scar records for comparison. |

## processed/

Written by the scripts in `code/`. Safe to delete and regenerate.

## archive/

Earlier hand-built tables, the earlier CALIB calibration, and superseded copies. Kept for reference; several contain known errors (for example the wrong depth for the shallowest GOV-01 date). `to_review/` holds files whose status is undecided.
