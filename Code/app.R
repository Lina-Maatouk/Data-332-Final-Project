library(shiny)
library(ggplot2)
library(leaflet)
library(DT)
library(dplyr)
library(caret)
rm(list = ls())

# Assuming 'subset_data' is a valid data frame with the required columns
subset_data <- readRDS("subset.rds")
location_topic_data <- readRDS("location_topic.rds")

# Get unique values of 'LocationAbbr' column
unique_locations <- unique(subset_data$LocationAbbr)

# Define UI
ui <- fluidPage(
  tabsetPanel(
    tabPanel("Disease Prevalence",
             selectInput("state", "Select State:", choices = unique_locations),
             plotOutput("chart1")),
    tabPanel("Disease Prevalence Comparison by State",
             selectInput("topic", "Select Topic:", choices = unique(subset_data$Topic)),
             plotOutput("chart2")),
    tabPanel("Map",
             checkboxGroupInput("topics", "Select Topics:", choices = unique(subset_data$Topic)),
             leafletOutput("map")),
    tabPanel("Location",
             selectInput("location", "Select Location", choices = unique_locations),
             DT::dataTableOutput("table")),
    tabPanel("Regression Prediction",
             selectInput("disease", "Select Disease:", choices = unique(subset_data$Question)),
             actionButton("predictBtn", "Predict"),
             textOutput("predictionText"))
  )
)

server <- function(input, output) {
  
  # Render the chart 1
  output$chart1 <- renderPlot({
    filtered_df <- subset_data[subset_data$LocationAbbr == input$state, ]
    
    ggplot(filtered_df, aes(x = Topic, fill = Topic)) +
      geom_bar() +
      ggtitle(paste("Disease Prevalence in", input$state)) +
      theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
      scale_fill_manual(values = rainbow(length(unique(filtered_df$Topic))))
  })
  
  # Render the chart 2
  output$chart2 <- renderPlot({
    filtered_df <- subset_data[subset_data$Topic == input$topic, ]
    
    ggplot(filtered_df, aes(x = LocationAbbr, fill = Topic)) +
      geom_bar() +
      ggtitle(paste("Disease Prevalence Comparison by State")) +
      theme(legend.position = "right", plot.title = element_text(hjust = 0.5))
  })
  
  # Render the map
  output$map <- renderLeaflet({
    selected_topics <- input$topics
    
    leaflet() %>%
      addTiles() %>%
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>%
      addCircleMarkers(data = subset_data[subset_data$Topic %in% selected_topics, ],
                       lng = ~Lon,
                       lat = ~Lat,
                       radius = 5,
                       color = "red",
                       fillColor = "red",
                       fillOpacity = 0.5,
                       popup = ~paste("State: ", LocationDesc, "<br>Disease: ", Question))
  })
  
  # Render the table
  output$table <- DT::renderDataTable({
    filtered_data <- subset_data[subset_data$Location
                                 