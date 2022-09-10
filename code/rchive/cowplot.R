# working with cowplot
library(ggplot2)
library(cowplot)

require(cowplot)
theme_set(theme_cowplot())
bd_boxplot <- ggplot(char_mass_bd_out) + geom_boxplot(aes(char_mass_bd_out$sample_id, char_mass_bd_out$bulk_density), fill = "grey") + labs(x = "Depth category", y = "Bulk Density (grams per cubic centimeter)", title = "Bulk Density across depth across all sites")
charcoal_boxplot <- ggplot(char_mass, aes(x = char_mass$sample_id, y = char_mass$char_concentration)) + geom_boxplot( fill = "grey", ) + labs(title = "Charcoal Concentrations across depth", x = "Depth Category", y = "Charcoal Concentration (mg/g)")
plot_grid(bd_boxplot, charcoal_boxplot, labels = "AUTO")

bd_boxplot + background_grid(major = "xy")
charcoal_boxplot + background_grid(major = "xy")


ggplot(char_mass, aes(x = char_mass$depth, y = char_mass$char_concentration)) + geom_boxplot()
+ scale_x_discrete("char_mass$depth", labels = c("0-50", "50-100", "100-150", "150-200", "200-250", "250-300", "300-350"))
str(char_mass$depth)       
as.character(char_mass$depth)
as.numeric(as.character(char_mass$depth))

ggplot(char_mass, aes(x = char_mass$depth, y = char_mass$char_concentration)) + geom_boxplot()

char_mass %>%
  mutate(char_mass$depth = fct_relevel(char_mass$depth, "0-50", "50-100", "100-150", "150-200", "200-250", "250-300", "300-350")) %>%
  ggplot(char_mass, aes(char_mass$depth, char_mass$char_concentration)) + geom_boxplot()

char_mass %>%
  mutate(char_mass$depth = fct_relevel(char_mass$depth, char_mass$char_concentration, fun = median)) %>%
  ggplot(char_mass, aes(char_mass$depth, char_mass$char_concentration)) + geom_boxplot()
