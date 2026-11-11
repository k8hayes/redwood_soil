#!/usr/bin/env bash
# One-off reorganisation of the redwood_soil repository (November 2026).
#
# Run once from the repository root:   bash reorganise_repository.sh
# Then review with `git status` and commit.
#
# What it does
#   - moves raw inputs into data/raw/ under clearer names
#   - moves hand-built intermediates and superseded copies into data/archive/
#   - moves superseded scripts and notebooks into code/archive/ and analysis/archive/
#   - moves field notes, site photos and maps into docs/
#   - deletes a file only if it is empty or byte-identical to a file that is kept;
#     anything that was expected to be a duplicate but is not goes to
#     data/archive/to_review/ instead
#
# Tracked files are moved with `git mv`, so history is kept. Missing files
# are skipped, so the script is safe to re-run.

set -u

if [ ! -f redwood_soil.Rproj ]; then
  echo "Run this from the repository root (redwood_soil.Rproj not found)." >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ] && [ "${ALLOW_UNCOMMITTED:-0}" != "1" ]; then
  echo "There are uncommitted changes. Commit them first so this move can be undone:" >&2
  echo "  git add -A && git commit -m 'Add analysis scripts before reorganisation'" >&2
  echo "(or re-run with ALLOW_UNCOMMITTED=1 to skip this check)" >&2
  exit 1
fi

moved=0; removed=0; skipped=0; review=0

is_tracked() { git ls-files --error-unmatch -- "$1" >/dev/null 2>&1; }

# move_item SOURCE DESTINATION  (files or whole folders)
move_item() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then skipped=$((skipped + 1)); return; fi
  if [ -e "$dst" ]; then echo "NOT MOVED (destination exists): $src -> $dst"; return; fi
  mkdir -p "$(dirname "$dst")"
  if [ -n "$(git ls-files -- "$src")" ] && git mv -- "$src" "$dst" 2>/dev/null; then :
  else mv -- "$src" "$dst"; fi
  moved=$((moved + 1))
}

# remove_item FILE  (a file that newer code replaces)
remove_item() {
  local f="$1"
  if [ ! -e "$f" ]; then skipped=$((skipped + 1)); return; fi
  if is_tracked "$f"; then git rm -q -- "$f"; else rm -- "$f"; fi
  removed=$((removed + 1))
}

# remove_duplicate FILE KEPT_COPY  (deleted only if byte-identical)
remove_duplicate() {
  local f="$1" kept="$2"
  if [ ! -e "$f" ]; then skipped=$((skipped + 1)); return; fi
  if [ -e "$kept" ] && cmp -s -- "$f" "$kept"; then
    remove_item "$f"
  else
    echo "NOT A DUPLICATE, sent to data/archive/to_review/: $f"
    move_item "$f" "data/archive/to_review/$(basename "$f")"
    review=$((review + 1))
  fi
}

# ---------------------------------------------------------------------------
# 1. Exact duplicates, empty files and stray files (checked before any move)
# ---------------------------------------------------------------------------
remove_duplicate "data/site_locations/char_sites copy.csv"   "data/site_locations/char_sites.csv"
remove_duplicate "data/site_locations/site_data.csv"         "data/char_samples.csv"
remove_duplicate "data/site_pictures/Headwaters1 copy.pdf"   "data/site_pictures/Headwaters1.pdf"
remove_duplicate "data/site_pictures/Headwaters.pdf"         "gis/Headwaters.pdf"
remove_duplicate "data/site_pictures/Headwaters_2016.pdf"    "gis/Headwaters_2016.pdf"

# Zero-byte photos (failed syncs)
if [ -d data/site_pictures ]; then
  while IFS= read -r -d '' empty_file; do remove_item "$empty_file"; done \
    < <(find data/site_pictures -type f -size 0 -print0)
fi

remove_item "data/site_locations/.~lock.redwood site data.csv#"

# ---------------------------------------------------------------------------
# 2. Raw inputs -> data/raw/
#    (radiocarbon_dates.csv, core_dry_mass.csv and sites.csv are already there)
# ---------------------------------------------------------------------------
move_item "data/raw/costech_results.csv"   "data/raw/elemental_results.csv"
move_item "data/Hayes_soil_costech.xlsx"   "data/raw/elemental_results_lab_workbook.xlsx"
move_item "data/char_mass_sieve.csv"       "data/raw/sieved_charcoal_mass.csv"

move_item "data/lab_work_backups/Lab_work_2_12.xlsx"  "data/raw/lab_workbook.xlsx"
move_item "data/lab_work_backups/old KMD data.xlsx"   "data/raw/lab_workbook_august_2017_subsamples.xlsx"

move_item "data/c14/c14_submissions/reports/GavinBrown report 110816.xls" "data/raw/cams_reports/GavinBrown report 110816.xls"
move_item "data/c14/Copy of GavinBrown report 061917.xls"                  "data/raw/cams_reports/GavinBrown report 061917.xls"
move_item "data/c14/c14_submissions/reports/GavinBrown report 091217.xls" "data/raw/cams_reports/GavinBrown report 091217.xls"
move_item "data/c14/c14_submissions/submission_forms"                      "data/raw/cams_submission_forms"
move_item "data/c14/c14_submissions/c14 samples .xlsx"                     "data/raw/charcoal_sample_inventory.xlsx"

move_item "data/redwood_fireevents.csv"                 "data/raw/fire_scar_events.csv"
move_item "data/redwood_fire_history_literature.xlsx"   "data/raw/fire_history_literature.xlsx"

# ---------------------------------------------------------------------------
# 3. Superseded and hand-built files -> data/archive/
# ---------------------------------------------------------------------------
# Old date tables (several carry the wrong depth for the shallowest GOV-01 date)
move_item "data/dates.csv"         "data/archive/date_tables/dates.csv"
move_item "data/dates.xlsx"        "data/archive/date_tables/dates.xlsx"
move_item "data/red14_bchron.csv"  "data/archive/date_tables/red14_bchron.csv"
move_item "data/red14_bchron.xlsx" "data/archive/date_tables/red14_bchron.xlsx"
move_item "data/c14inp.csv"        "data/archive/date_tables/c14inp.csv"
move_item "data/char_samples.csv"  "data/archive/date_tables/char_samples.csv"
move_item "data/bchron"            "data/archive/date_tables/bchron"

# Earlier CALIB calibration (read by code/01_calibrate-dates.R for comparison)
move_item "data/calout.csv"            "data/archive/calibration_calib/calout.csv"
move_item "data/c14/calib/calout.csv"  "data/archive/calibration_calib/calout_second_copy.csv"
move_item "data/c14/calib"             "data/archive/calibration_calib/calib_session_files"

# Spreadsheet-built results that code now regenerates
move_item "data/gm2.xlsx"        "data/archive/hand_built/gm2.xlsx"
move_item "data/gm2all.csv"      "data/archive/hand_built/gm2all.csv"
move_item "data/gm2all.xlsx"     "data/archive/hand_built/gm2all.xlsx"
move_item "data/gm2sums.csv"     "data/archive/hand_built/gm2sums.csv"
move_item "data/ratios.csv"      "data/archive/hand_built/ratios.csv"
move_item "data/comparison.csv"  "data/archive/hand_built/comparison.csv"
move_item "data/comparison.xlsx" "data/archive/hand_built/comparison.xlsx"
move_item "data/overlap.xlsx"    "data/archive/hand_built/overlap.xlsx"
move_item "data/kmd_data.csv"    "data/archive/hand_built/kmd_data.csv"
move_item "data/kmd_data.xlsx"   "data/archive/hand_built/kmd_data.xlsx"
move_item "data/age_reverse.csv" "data/archive/hand_built/age_reverse.csv"
move_item "data/c14/age_reversal" "data/archive/hand_built/age_reversal"
move_item "data/processed/costech_results_process.csv" "data/archive/hand_built/costech_results_process.csv"
move_item "data/raw/costech_results.xlsx"              "data/archive/hand_built/costech_results.xlsx"

# Site tables that data/raw/sites.csv replaces
move_item "data/site_locations"  "data/archive/site_locations"
move_item "data/site data.xlsx"  "data/archive/site_locations/site data.xlsx"

# Other copies of the lab workbook
move_item "data/lab_work_backups" "data/archive/lab_workbook_versions"

# Two versions of the charcoal counts; keep one after checking which is current
move_item "data/charcoal counts.xlsx" "data/archive/to_review/charcoal counts.xlsx"
move_item "data/charcoal_counts.xlsx" "data/archive/to_review/charcoal_counts.xlsx"

# ---------------------------------------------------------------------------
# 4. Field notes, photos and maps -> docs/
# ---------------------------------------------------------------------------
move_item "data/field_notes"   "docs/field_notes"
move_item "data/site_pictures" "docs/site_pictures"
move_item "gis"                "docs/maps"
move_item "# PROMPT.md"        "docs/archive/PROMPT_holocene_formatting.md"

# ---------------------------------------------------------------------------
# 5. Code
# ---------------------------------------------------------------------------
# Earlier names of the pipeline scripts (renumbered copies are already in code/)
remove_item "code/02_calibrate-dates.R"
remove_item "code/03_charcoal-stratigraphy.R"
remove_item "code/05_summed-probability.R"

# Scripts replaced by the new pipeline and figure scripts
move_item "code/01_process-costech.R" "code/archive/01_process-costech.R"
move_item "code/Abundance_new.R"      "code/archive/Abundance_new.R"
move_item "code/rcarbon.R"            "code/archive/rcarbon.R"
move_item "code/Fig2_carbonratio.R"   "code/archive/Fig2_carbonratio.R"
move_item "code/FIg3_agedepth.R"      "code/archive/Fig3_agedepth.R"
move_item "code/FigS1_bulkdensity.R"  "code/archive/FigS1_bulkdensity.R"
move_item "code/Fig1_map.R"           "code/fig1_map.R"

# ---------------------------------------------------------------------------
# 6. Analysis notebooks (redwood_analysis.qmd stays)
# ---------------------------------------------------------------------------
move_item "analysis/bchron_analysis.Rmd" "analysis/archive/bchron_analysis.Rmd"
move_item "analysis/bchron.rmd"          "analysis/archive/bchron.rmd"
move_item "analysis/costech.Rmd"         "analysis/archive/costech.Rmd"
move_item "analysis/costech.nb.html"     "analysis/archive/costech.nb.html"
move_item "analysis/site data.Rmd"       "analysis/archive/site data.Rmd"
move_item "analysis/thesis.Rmd"          "analysis/archive/thesis.Rmd"

# ---------------------------------------------------------------------------
# 7. Figures made by the old scripts
# ---------------------------------------------------------------------------
move_item "output/figures/Fig2_carbonratio.png"   "output/figures/archive/Fig2_carbonratio.png"
move_item "output/figures/Fig3_agedepth.png"      "output/figures/archive/Fig3_agedepth.png"
move_item "output/figures/FigS1_bulkdensity.png"  "output/figures/archive/FigS1_bulkdensity.png"
move_item "output/figures/FigS2_methodcompar.png" "output/figures/archive/FigS2_methodcompar.png"

# Remove folders the moves left empty
find data -type d -empty -delete 2>/dev/null

echo
echo "Moved: $moved   Deleted (empty, duplicate or superseded): $removed"
echo "Sent to data/archive/to_review/: $review   Not found (skipped): $skipped"
echo "Review with 'git status', then commit. This script can then be deleted."
