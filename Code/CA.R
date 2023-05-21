library(shiny)
library(tidyr)
library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(leaflet)
library(caret)

rm(list=ls())

setwd("C:/Users/linamaatouk21/Documents/FinalProject")

# Read and save as RDS (2017-2021) and select relevant columns
ca_2021 <- read.csv("2021_ca.csv")
saveRDS(ca_2021, file = "2021_ca.rds")
ca_2021 <- readRDS("2021_ca.rds") %>% 
  mutate(Year = 2021, .before = 1) %>%
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME, Year)

ca_2020 <- read.csv("2020_ca.csv")
saveRDS(ca_2020, file = "2020_ca.rds")
ca_2020 <- readRDS("2020_ca.rds") %>% 
  mutate(Year = 2020, .before = 1) %>%
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME, Year)

ca_2019 <- read.csv("2019_ca.csv")
saveRDS(ca_2019, file = "2019_ca.rds")
ca_2019 <- readRDS("2019_ca.rds") %>% 
  mutate(Year = 2019, .before = 1) %>%
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME, Year)

ca_2018 <- read.csv("2018_ca.csv")
saveRDS(ca_2018, file = "2018_ca.rds")
ca_2018 <- readRDS("2018_ca.rds") %>% 
  mutate(Year = 2018, .before = 1) %>%
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME, Year)


# Rename columns
colnames(ca_2021) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                            "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName", "Year")

colnames(ca_2020) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                       "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName", "Year")

colnames(ca_2019) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                       "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName", "Year")

colnames(ca_2018) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                       "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName", "Year")


combined_data <- rbind(ca_2018, ca_2019, ca_2020, ca_2021)

# Select top 10 chemicals for each year
top_chemicals <- combined_data %>%
  group_by(Year, Chemical) %>%
  summarise(OnSiteReleaseTotal = sum(OnSiteReleaseTotal)) %>%
  arrange(Year, desc(OnSiteReleaseTotal)) %>%
  group_by(Year) %>%
  top_n(10) %>%
  ungroup()

# Filter combined_data for top chemicals
filtered_data <- combined_data %>%
  inner_join(top_chemicals, by = c("Year", "Chemical"))

# Perform data preprocessing
filtered_data <- filtered_data %>%
  mutate(Year = as.integer(Year),    
         OnSiteReleaseTotal = as.numeric(OnSiteReleaseTotal.x),  

  )

# Handle missing values
filtered_data <- na.omit(filtered_data) 

# Model training
model <- train(OnSiteReleaseTotal ~ Year, data = filtered_data, method = "lm")

# Create sub-data frame with required columns for map
map_data <- ca_2021 %>% 
  select(Latitude, Longitude, Chemical, FacilityName)

#Shiny app
ui <- fluidPage(
  titlePanel("Chemical Releases in California"),
  tabsetPanel(
    tabPanel("Data Plot",
             "This tab displays a plot of the chemical releases in California based on data from the years 2018 to 2021. 
             You can select a chemical and use a prediction model to estimate the releases for the next following years.",
             sidebarLayout(
               sidebarPanel(
                 selectInput("chemical", "Select Chemical", choices = unique(filtered_data$Chemical)),
                 actionButton("predictBtn", "Predict")
               ),
               mainPanel(
                 plotOutput("plot")
               )
             )
    ),
    tabPanel("Chemical Releases in California in 2021",
             "This tab displays a map of the chemical releases in California in 2021.
             Click on the red dots to display the Facility Name and Chemical released.",
             leafletOutput("map")
    )
  )
)

server <- function(input, output) {
  filtered_data_reactive <- reactive({
    filtered_data %>%
      filter(Chemical == input$chemical)
  })
  
  model_reactive <- reactive({
    train(OnSiteReleaseTotal ~ Year, data = filtered_data_reactive(), method = "lm")
  })
  
  # Reactive expression for prediction
  prediction_reactive <- reactive({
    new_years <- data.frame(Year = 2022:2025)  # Change the years as per your requirement
    new_years$PredictedOnSiteReleaseTotal <- predict(model_reactive(), newdata = new_years)
    new_years
  })
  
  # Render the data plot
  output$plot <- renderPlot({
    if (input$predictBtn) {
      model <- model_reactive()
      prediction <- prediction_reactive()
      
      ggplot() +
        geom_point(data = filtered_data_reactive(), aes(x = Year, y = OnSiteReleaseTotal), color = "steelblue") +
        geom_line(data = prediction, aes(x = Year, y = PredictedOnSiteReleaseTotal), color = "red") +
        labs(x = "Year", y = "On-Site Release Total",
             title = paste("Prediction for Chemical:", input$chemical)) +
        theme_minimal()
    } else {
      ggplot(data = filtered_data_reactive(), aes(x = Year, y = OnSiteReleaseTotal)) +
        geom_point(color = "steelblue") +
        labs(x = "Year", y = "On-Site Release Total",
             title = paste("Data for Chemical:", input$chemical)) +
        theme_minimal()
    }
  })
  
  # Render the map
  output$map <- renderLeaflet({
    leaflet(map_data) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~Longitude,
        lat = ~Latitude,
        popup = ~paste("Facility Name: ", FacilityName, "<br>",
                       "Chemical: ", Chemical),
        color = "darkred",
        fillOpacity = 0.4,
        radius = 5
      )
  })
}

shinyApp(ui = ui, server = server)


