install.packages("ggridges")
library(ggridges)
library(cowplot)

dates <- read.csv("overlap.csv")
dates <- dates[which(dates$date <=400),]

ggplot(data = dates, aes(x = dates$date)) + 
  geom_density(aes(fill = dates$type), alpha = 0.8) 


plot(dates$date)


ggplot(data = dates, aes(x = dates$date, color = dates$type)) + 
  geom_histogram(aes(y = ..density..),binwidth = 10, fill = "white", position = "identity") +
  geom_density(size = 1, alpha = 0.2) + scale_color_manual(values = c("#868686FF", "#EFC000FF"))


ggplot(dates, aes(x = dates$date, fill = dates$type)) + 
  geom_area(stat = "bin", bins = 10)

ggplot(dates, aes(x = date, fill = type)) + 
  geom_dotplot(binwidth = 10, dotsize = 2.5, 
               alpha = 0.8, method = "histodot", stackgroups  = T) + 
  scale_y_continuous(NULL, breaks = NULL) + 
  scale_fill_manual(values = c("#868686FF", "#EFC000FF"), labels = c("Soil Charcoal Dates", "Tree-Ring Dates")) +
  labs(x = "Year BP", fill = "Record")


