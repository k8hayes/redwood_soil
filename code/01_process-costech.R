## --------------------------------------------------------------- ##
## Redwood Charcoal Analysis
##
## 01 - Process costech results
## --------------------------------------------------------------- ##
# Code written by: Kate Hayes (khayes23@alaska.edu)
# Fall 2026

# Set up ###############################
costech_raw <- read.csv(here("data/raw/costech_results.csv"))

costech <- costech_raw %>%
  rename("depth" = "depth_category") %>%
  filter(type == "kmd" | type == "raw") %>%
  filter(depth != "G") 

costech = costech %>%
  mutate(depth = ifelse(depth == "A", "0-5",
                         ifelse(depth == "B", "5-10",
                                ifelse(depth == "C", "10-15",
                                       ifelse(depth == "D", "15-20",
                                              ifelse(depth == "E", "20-25", "25-30"))))))

costech$depth <- factor(costech$depth, ordered = TRUE,
                        levels = c("0-5", "5-10", "10-15",
                                   "15-20", "20-25", "25-30"))

costech = costech %>%
  select(site, site_name, Sample_id, depth, mg.Carbon, C_percent, site_type, type)

write.csv(costech, "data/processed/costech_results_process.csv", row.names = F)
