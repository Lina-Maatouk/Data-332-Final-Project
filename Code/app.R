library(shinythemes)
library(ggplot2)
library(leaflet)
library(plotly)
library(dplyr)
library(caret)
library(shiny)

# setwd("C:/Users/linamaatouk21/Documents/FinalProject")

# Read data
ca_2021 <- readRDS("RDS/2021_ca.rds")
ca_2020 <- readRDS("RDS/2020_ca.rds")
ca_2019 <- readRDS("RDS/2019_ca.rds")
ca_2018 <- readRDS("RDS/2018_ca.rds")

combined_data <- readRDS(file = "RDS/combined_data.rds")

# Select top 10 chemicals for each year
top_chemicals <- combined_data %>%
  group_by(Year, Chemical) %>%
  summarise(OnSiteReleaseTotal = sum(OnSiteReleaseTotal)) %>%
  arrange(Year, desc(OnSiteReleaseTotal)) %>%
  group_by(Year) %>%
  top_n(10) %>%
  ungroup()

# Read filtered data for top chemicals
filtered_data <- readRDS(file = "RDS/filtered_data.rds")

# Create sub data frame with required columns for map
map_data <- ca_2021 %>% 
  select(Latitude, Longitude, Chemical, FacilityName)

# Read US data
main_data <- readRDS("RDS/2021_us.rds")

# Create sub-data frame with relevant columns
toxic_locations <- main_data %>% 
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME) 

# Rename columns
colnames(toxic_locations) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                               "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName")

# Read sub data frames for each region of the US:

northeast_df <- readRDS(file = "RDS/northeast_trimmed.rds")
midwest_df <- readRDS(file = "RDS/midwest_trimmed.rds")
south_df <- readRDS(file = "RDS/south_trimmed.rds")
west_df <- readRDS(file = "RDS/west_trimmed.rds")

ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Chemical Releases Analysis"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Chemical Releases by Region",
                 selectInput("region", "Select Region:",
                             choices = c("Northeast", "Midwest", "South", "West"),
                             selected = "Northeast")
        ),
        tabPanel("Chemical Releases in California",
                 selectInput("chemical", "Select Chemical",
                             choices = unique(filtered_data$Chemical)),
                 actionButton("predictBtn", "Predict")
        )
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Table", tableOutput("table"), "This tab displays the table of chemical releases."),
        tabPanel("Graph", plotlyOutput("graph"), "This tab displays the graph of top 10 chemical releases."),
        tabPanel("Data Plot", plotOutput("plot"), "This tab displays a plot of the chemical releases in California based on data from the years 2018 to 2021. You can select a chemical and use a prediction model to estimate the releases for the next following years."),
        tabPanel("Chemical Releases in California in 2021", leafletOutput("map"), "This tab displays a map of chemical releases in California in 2021. Click on the markers to see which facility released which chemical.")
      )
    )
  )
)

server <- function(input, output) {
  # Reactive function to filter data based on selected region
  region_data <- reactive({
    switch(input$region,
           "Northeast" = northeast_df,
           "Midwest" = midwest_df,
           "South" = south_df,
           "West" = west_df)
  })
  
  # Render the table
  output$table <- renderTable({
    req(region_data())
    region_data()
  })
  
  # Render the graph
  output$graph <- renderPlotly({
    req(region_data())
    
    colors <- c("#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#00FFFF", "#FF00FF", "#800000", "#008000", "#000080", "#808000")
    
    plot_ly(region_data(), x = ~Chemical, y = ~TotalRelease, type = "bar",
            marker = list(color = colors),
            hoverinfo = "none") %>%
      layout(title = "Top 10 Chemical Releases",
             xaxis = list(title = "Chemical"),
             yaxis = list(title = "Total Release"),
             showlegend = FALSE)
  })
  
  # Reactive expression for filtering data based on selected chemical
  filtered_data_reactive <- reactive({
    filtered_data %>%
      filter(Chemical == input$chemical)
  })
  
  # Reactive expression for model training
  model_reactive <- reactive({
    train(OnSiteReleaseTotal ~ Year, data = filtered_data_reactive(), method = "lm")
  })
  
  # Reactive expression for prediction
  prediction_reactive <- reactive({
    if (input$predictBtn) {
      new_years <- data.frame(Year = 2022:2025)  # Change the years as per your requirement
      new_years$PredictedOnSiteReleaseTotal <- predict(model_reactive(), newdata = new_years)
      new_years
    } else {
      NULL
    }
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