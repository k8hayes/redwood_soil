# redwood_soil

Data and analysis for "Soil carbon and charcoal show fire was abundant in prehistoric coast redwood forests" by Katherine Hayes, Lucas C.R. Silva and Daniel G. Gavin (in preparation).

The study dates soil charcoal and measures total and pyrogenic carbon in old-growth coast redwood soils at the Headwaters Forest Reserve, Humboldt County, California.

Please do not share these data without permission of the lead author, Katherine Hayes (hayesk7@wwu.edu).

## How to run

1. Open `redwood_soil.Rproj` in RStudio.
2. Open `analysis/redwood_analysis.qmd` and run the chunks in order from a fresh session.

The first chunk installs and loads the packages (`librarian`, `tidyverse`, `cowplot`, `here`, `rcarbon`, `terra`, `tidyterra`). The last chunk prints the session information.

## What the analysis does

| Script | Reads | Writes |
|---|---|---|
| `code/01_calibrate-dates.R` | `data/raw/radiocarbon_dates.csv` | calibrated dates, Table 1, comparison with the earlier CALIB calibration |
| `code/02_charcoal-stratigraphy.R` | calibrated dates | age-depth pairs and their classes |
| `code/03_summed-probability.R` | calibrated dates | summed probability table and Figure 4 |
| `code/04_carbon-stocks.R` | `data/raw/elemental_results.csv`, `data/raw/core_dry_mass.csv` | concentrations and stocks per sample and site, summary tables |
| `code/fig2_carbon_by_depth.R` | carbon by sample | Figure 2 |
| `code/fig3_age_depth.R` | calibrated dates, pairs | Figure 3 |
| `code/figS1_bulk_density.R` | carbon by sample | Figure S1 |
| `code/figS2_method_comparison.R` | carbon by sample, `data/raw/sieved_charcoal_mass.csv` | Figure S2, method comparison tables |

`code/fig1_map.R` (Figure 1) is not yet part of the run.

## Folders

- `data/raw/`: inputs. Never edited by code. See `data/README.md`.
- `data/processed/`: tables written by the scripts.
- `data/archive/`: earlier hand-built tables and superseded copies, kept for reference. Only `data/archive/calibration_calib/calout.csv` is read by the code.
- `code/`: scripts, run in number order; `code/archive/` holds superseded scripts.
- `analysis/`: the Quarto document that runs everything; `analysis/archive/` holds earlier notebooks.
- `output/figures/`, `output/tables/`: figures and tables for the manuscript.
- `docs/`: field notes, site photos and maps.

## Choices that affect results

- Core results use the top 30 cm (six 5 cm rings). The unringed bottom sample is excluded.
- Each core sample was dried in two parts. `add_subsample_mass` in `code/04_carbon-stocks.R` controls whether the August 2017 subsample is added to the sample mass (default: yes).
- Dates are calibrated with `rcarbon` and IntCal20. The two post-1950 dates are not calibrated.
- One date, HEAD-04d83, is excluded through the `use_in_analysis` column of `data/raw/radiocarbon_dates.csv`.
