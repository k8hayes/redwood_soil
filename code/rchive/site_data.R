# working with site data
site_data <- read.csv(file = "char_sites.csv")

# first, need to extract charcoal data for each site
ridg_01_char <- char_mass[which(char_mass$Site_id == "RIDG_01"),]
ridg_02_char <- char_mass[which(char_mass$Site_id == "RIDG_02"),]
ridg_char <- merge(ridg_01_char, ridg_02_char, all = TRUE)

eels_char <- char_mass[which(char_mass$Site_id == "EELS_01"),]
eels_01_char <- eels_char

salm_01_char <- char_mass[which(char_mass$Site_id == "SALM_01"),]
salm_02_char <- char_mass[which(char_mass$Site_id == "SALM_02"),]
salm_03_char <- char_mass[which(char_mass$Site_id == "SALM_03"),]
salm_char <- merge(merge(salm_01_char, salm_02_char, all = TRUE), salm_03_char, all = TRUE)

worf_01_char <- char_mass[which(char_mass$Site_id == "WORF_01"),]
worf_02_char <- char_mass[which(char_mass$Site_id == "WORF_02"),]
worf_03_char <- char_mass[which(char_mass$Site_id == "WORF_03"),]
worf_04_char <- char_mass[which(char_mass$Site_id == "WORF_04"),]
worf_05_char <- char_mass[which(char_mass$Site_id == "WORF_05"),]
worf_char <- merge(merge(worf_01_char, worf_02_char, all = TRUE), merge(merge(worf_03_char, worf_04_char, all = TRUE), worf_05_char, all = TRUE), all = TRUE)

wolf_01_char <- char_mass[which(char_mass$Site_id == "WOLF_01"),]
wolf_02_char <- char_mass[which(char_mass$Site_id == "WOLF_02"),]
wolf_03_char <- char_mass[which(char_mass$Site_id == "WOLF_03"),]
wolf_04_char <- char_mass[which(char_mass$Site_id == "WOLF_04"),]
wolf_char <- merge(merge(wolf_01_char, wolf_02_char, all = TRUE), merge(wolf_03_char, wolf_04_char, all = TRUE), all = TRUE)

gog_01_char <- char_mass[which(char_mass$Site_id == "GOG_01"),]
gog_02_char <- char_mass[which(char_mass$Site_id == "GOG_02"),]
gog_char <- merge(gog_01_char, gog_02_char , all = TRUE)


# this is the long way to do this 
# averages <- c(mean(eels_char$total.mass), mean(salm_char$total.mass), mean(ridg_char$total.mass), mean(worf_char$total.mass), mean(wolf_char$total.mass), mean(gog_char$total.mass))
# sds <- c(sd(eels_char$total.mass), sd(salm_char$total.mass), sd(ridg_char$total.mass), sd(worf_char$total.mass), sd(wolf_char$total.mass), sd(gog_char$total.mass))
# sites <- c("eels", "salm", "ridg", "worf", "wolf", "gog")
# site_char <- data.frame(sites, averages, sds)

# let's see if i can replicate this using the tapply function
site_averages <- tapply(char_mass$total.mass,char_mass$Site_id, mean) #yep
site_sums <- tapply(char_mass$total.mass, char_mass$Site_id, sum)
site_sds <- tapply(char_mass$total.mass, char_mass$Site_id, sd)

site_char <- data.frame(site_averages, site_sums, site_sds)

# it looks like i need to change the site types in one of my files so that i can directly compare the mass numbers to the location
  # char_mass uses RIDG_01_02, but site_data uses RIDG_01
  # i think i'll change them in char_mass: i could do this in excel, but i don't want to mess with the code I've already written, and i could use the pratice in r
# so 
# char_mass$Site_id[which(char_mass$Site_id == "RIDG_01_03")] <- "RIDG_01"
# just kidding the above introduced NAs, so i changed the values in the csv file, and i'll edit the above code as well

# begining to plot data 4/15
# let's do some basic ones:
plot(site_data$elevation, site_char$site_sums) # forgot that site_data also has data for the radiocarbon dates
# going to need to make a new file, of just the bulk sample sites 



# this is something to do after reorganizing the data a bit (!!!)
#boxplot of char data at each site cluster
boxplot(site_char$averages ~ site_char$sites, data= site_char)

char_sites_bpl <- ggplot(site_char, aes(site_char$sites, site_char$averages))
char_sites_bpl + geom_boxplot(aes(group = cut_width(site_char$sites, 1)), outlier.alpha = 0.25) 
#+ labs(title = "Average mass of charcoal per depth (sieving)", x = "Sample depth category", y = "Total mass of charoal (mg)")





