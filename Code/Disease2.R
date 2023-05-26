library(shiny)
library(dplyr)
library(ggplot2)
library(leaflet)
library(leaflet.extras)

library(tmaptools)


rm(list = ls())
setwd("~/Desktop/disease")
df<-read.csv("U.S._Chronic_Disease_Indicators__CDI_ (1).csv")

df_1 = df[,c(1,3,4,6,7,18,23,24)]

df_1$Lat <- as.numeric(gsub("[()]", "", df$Lat))
df_1$Lon <- as.numeric(gsub("[()]", "", df$Lon))
df_1 <- df_1[complete.cases(df_1), ]

num_rows <- 1000  # Specify the number of rows you want

# Get a random subset of 'num_rows' rows from the dataset
subset <- dplyr::sample_n(df_1, num_rows, replace = FALSE)
saveRDS(subset, file = "subset.rds")

#By locataion
location_topic <- subset %>% 
  group_by(LocationAbbr,Topic) %>% 
  dplyr::summarize(Total = n())


write.csv(location_topic, "location_topic.csv", row.names = FALSE)
saveRDS(location_topic, file = "location_topic.rds")
df_3<-location_topic%>%
  arrange(desc(location_topic$Total))

write.csv(location_topic_desc, "location_topic_desc.csv", row.names = FALSE)
# Prevalence of Disease
ggplot(location_topic, aes(Topic, Total, fill=Topic)) + 
  geom_bar(stat="identity", aes(location_topic$Topic) 
           ) + 
  ggtitle("Prevalence of Disease in the US") + 
  theme(legend.position = "none", 
        plot.title = element_text(hjust = 0.5),)+
  geom_bar(stat = "identity") +
  ggtitle("Trips by the Hour") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))

#Prevalence of Disease by state

ggplot(location_topic, aes(LocationAbbr, Total, fill=Topic)) + 
  geom_bar(stat="identity", aes(location_topic$Topic) 
  ) + 
  ggtitle("Prevalence of Disease by State") + 
  theme(legend.position = "none", 
        plot.title = element_text(hjust = 0.5))+
  labs(fill = "Topic") +
  theme(legend.position = "right", plot.title = element_text(hjust = 0.5))


#map

map <- leaflet() %>%
  addTiles() %>%
  setView(lng = -95.7129, lat = 37.0902, zoom = 4)

topic_colors <- colorFactor(palette = c("red", "blue", "green"), domain = df_1$Topic)

# Add markers to the map
map <- map %>%
  addTiles(urlTemplate = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
           attribution = '© <a href="https://carto.com/attributions">Carto</a>') %>%
  
  addCircleMarkers(data = df_1 ,
                   lng = ~Lon,
                   lat = ~Lat,
                   radius = 5,
                   color = ~topic_colors(Topic),
                   fillOpacity = 0.5,
                   popup = ~paste("State: ", LocationDesc, "<br>Disease: ", Question))

# Display the map
map
