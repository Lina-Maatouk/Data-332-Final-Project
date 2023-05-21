library(shiny)
library(tidyr)
library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(caret)
library(shinythemes)
library(leaflet)
library(plotly)

rm(list=ls())

setwd("C:/Users/linamaatouk21/Documents/FinalProject")

#read as an rds file
main_data <- read.csv("2021_us.csv")
saveRDS(main_data, file = "2021_us.rds")
main_data <- readRDS("2021_us.rds")

# Create sub-data frame with relevant columns
toxic_locations <- main_data %>% 
  select(X2..TRIFD, X6..CITY, X7..COUNTY, X8..ST, X62..ON.SITE.RELEASE.TOTAL,
         X85..OFF.SITE.RELEASE.TOTAL, X12..LATITUDE, X13..LONGITUDE, X34..CHEMICAL, X4..FACILITY.NAME) 

# Rename columns
colnames(toxic_locations) <- c("TRIFD", "City", "County", "State", "OnSiteReleaseTotal",
                               "OffSiteReleaseTotal", "Latitude", "Longitude", "Chemical", "FacilityName")

#Create sub data frame for each region of the US:

##Northeast region:
northeast_df <- filter(toxic_locations, State %in% c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA"))

##Midwest region:
midwest_df <- filter(toxic_locations, State %in% c("IL", "IN", "IA", "KS", "MI", "MN", "MO", "NE", "ND", "OH", "SD", "WI"))

##South region:
south_df <- filter(toxic_locations, State %in% c("AL", "AR", "DE", "FL", "GA", "KY", "LA", "MD", "MS", "NC", "OK", "SC", "TN", "TX", "VA", "WV"))

##West region:
west_df <- filter(toxic_locations, State %in% c("AK", "AZ", "CA", "CO", "HI", "ID", "MT", "NV", "NM", "OR", "UT", "WA", "WY"))

# Trim the data to top 10 chemicals
trim_data <- function(data) {
  data %>%
    mutate(Chemical = as.character(Chemical)) %>%
    group_by(Chemical) %>%
    summarise(TotalRelease = sum(OnSiteReleaseTotal)) %>%
    arrange(desc(TotalRelease)) %>%
    top_n(10, TotalRelease)
}


# Trim data for each region
northeast_trimmed <- trim_data(northeast_df)
midwest_trimmed <- trim_data(midwest_df)
south_trimmed <- trim_data(south_df)
west_trimmed <- trim_data(west_df)



ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Chemical Releases by Region"),
  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Select Region:",
                  choices = c("Northeast", "Midwest", "South", "West"),
                  selected = "Northeast")
    ),
    mainPanel(
      tabsetPanel(
        id = "tabset",
        tabPanel("Table", tableOutput("table")),
        tabPanel("Graph", plotlyOutput("graph"))
      )
    )
  )
)
server <- function(input, output) {
  data <- reactive({
    switch(input$region,
           "Northeast" = northeast_trimmed,
           "Midwest" = midwest_trimmed,
           "South" = south_trimmed,
           "West" = west_trimmed)
  })
  
  # Render the table
  output$table <- renderTable({
    req(data())
    data()
  })
  
  # Render the graph
  output$graph <- renderPlotly({
    req(data())
    
    colors <- c("#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#00FFFF", "#FF00FF", "#800000", "#008000", "#000080", "#808000")
    
    plot_ly(data(), x = ~Chemical, y = ~TotalRelease, type = "bar",
            marker = list(color = colors),
            hoverinfo = "none") %>%
      layout(title = "Top 10 Chemical Releases",
             xaxis = list(title = "Chemical"),
             yaxis = list(title = "Total Release"),
             showlegend = FALSE)
  })
}

shinyApp(ui = ui, server = server)