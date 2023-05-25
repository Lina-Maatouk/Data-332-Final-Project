# Toxic Release and Chronic Disease 🔬

## Introduction: 

This project focuses on analyzing toxic chemical releases in the United States, with a specific emphasis on California (CA) and New York (NY) in 2021, aiming to uncover correlations with chronic diseases. Through advanced statistical techniques and data visualization in R, we explore potential associations between toxic releases and chronic disease prevalence rates. Additionally, we have developed a predictive model using historical data from 2018 to 2021 to forecast chemical releases in CA, assisting stakeholders in making informed decisions regarding environmental regulations and public health initiatives. This repository provides access to datasets, analysis scripts, prediction models, and insightful results, enabling further exploration and understanding of the complex relationship between toxic chemical releases and chronic diseases.


## Dependencies: 
* This code is an R script.
* The dataset needed is also provided in the following link: https://www.epa.gov/toxics-release-inventory-tri-program/tri-basic-data-files-calendar-years-1987-present

## 1. US Toxic release in 2021:biohazard:

- For the US dataset, we created sub data frames to see how the chemicals rate changes by region. We used filter function as showns below:

![USsubdataframe](https://github.com/Lina-Maatouk/Data-332-Final-Project/assets/118494394/837b69f1-47a5-45ee-a27d-550dc96a12dc)

- Then, we trimmed the sub datasets to focus on the top 10 chemical released.

![UStrimdata](https://github.com/Lina-Maatouk/Data-332-Final-Project/assets/118494394/12526667-2d31-494c-b325-37ab5c1e548d)


### Toxic release in California: 

Next, we decided to narrow our focus and chose to analyze the data from California. We combined the past datasets from 2018 to 2021 and build a prediction model using an LLM (OpenAI). 

![CAcleaning](https://github.com/Lina-Maatouk/Data-332-Final-Project/assets/118494394/2bea709b-65cd-4927-81b2-0dcef3781b4e)

### Prediction Model:

![CAprediction](https://github.com/Lina-Maatouk/Data-332-Final-Project/assets/118494394/83190e62-2875-4e44-935e-5c071d992a73)

OpenAI recommends this prediction model because it incorporates best practices for data collection, preprocessing, and modeling techniques. The model gathers data from multiple years (2018 to 2021) and applies appropriate data cleaning and transformation methods to handle missing values and ensure accurate analysis. By leveraging the caret package, the model employs a linear regression approach to establish a relationship between the year and on-site release total, enabling predictions for future years. The Shiny app interface enhances user experience by providing interactive data visualization and prediction capabilities, allowing users to explore and interpret the chemical release data effectively. With its comprehensive approach and user-friendly interface, this prediction model exemplifies the principles of robust data analysis and holds the potential to provide valuable insights into chemical releases in California.


#### Shiny app:

Please find the following link to access an interactive Shiny app that provides various features for exploring chemical releases data:

https://linamaatouk.shinyapps.io/Chemical-Release-Analysis/

Within the app, you will find the option "Chemical Releases by Region," allowing you to filter and select specific regions of interest. By doing so, you can view the total values of released chemicals and visualize the data through an intuitive bar chart. It is noteworthy that Nitrate stands out as the most prevalent chemical released across all regions.

Moreover, the app offers the choice to explore "Chemical Releases in California" specifically. Here, you can select a specific chemical name of interest and utilize the prediction feature to generate a data plot showcasing predicted values for the upcoming years.
The Shiny app also includes a geospatial map feature, where red markers represent facilities. By clicking on these markers, you can access information on the chemicals released by each facility in the year 2021.

### Analysis: 

Our analysis shows that the highest chemical released by most facilities in the US is nitrate compounds, raising serious concerns about their potential impact on chronic diseases. Nitrate compounds, commonly found in industrial and agricultural activities, have been associated with an increased risk of developing various chronic illnesses. When ingested or absorbed into the body, nitrates can undergo chemical reactions that convert them into nitrite and nitrosamines, known to be harmful substances. Nitrosamines, extensively studied, have been linked to the development of certain types of cancer such as stomach, bladder, and colon cancer, due to their ability to damage DNA, disrupt cellular processes, and promote the growth of cancerous cells. Long-term exposure to high nitrate levels through contaminated water or nitrate-rich foods may contribute to the initiation and progression of these chronic diseases. Moreover, excessive nitrate intake can lead to methemoglobinemia, or "blue baby syndrome," particularly harmful to infants as it reduces the blood's oxygen-carrying capacity. To mitigate the risks associated with nitrate compounds and chronic diseases, it is crucial to regulate their release into the environment, implement stricter pollution control measures, improve wastewater treatment systems, and promote sustainable agricultural practices. Regular monitoring of nitrate levels in drinking water sources and raising awareness about the potential health impacts are also vital for protecting public health.
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6068531/


## 2. Toxic release in NYC:biohazard:

### 1.	GeoSpatial Map

Its interactive map of New York state using the Leaflet package in R. The map would display circle markers at different locations on the map, representing various facilities.

Each circle marker represents a specific facility, and when clicked, a popup window would appear with additional information about that facility. The information displayed in the popup includes:

Facility Name: This would show the name or identifier of the facility represented by the marker.
State: It indicates the state where the facility is located, providing additional geographical context.
Zip Code: This shows the zip code associated with the facility's location.
Compound Released: It displays the information about the chemicals that were released or associated with the facility.
Street Address: This provides the street address of the facility's location, offering a more precise identification.

The use of Leaflet in this code allows for the visualization of geographic data in an interactive and visually appealing manner. It enables the exploration of facility locations, provides additional information about each facility through popups,
```R
    ny_map <- leaflet() %>%
      setView(-75.3470, 42.6953, zoom = 7) %>%
      addProviderTiles("CartoDB.Positron")

    # Convert the data frame to a leaflet-compatible format
    df_coords <- data.frame(lat = df_1$latitude, lng = df_1$Longitude, 
                            state = df_1$state, facility_name = df_1$facility_name,
                            zip = df_1$zip, chemicals = df_1$chemicals,Street_Address = df_1$Street_Address )

    # Add the markers to the map
    ny_map <- ny_map %>%
      addCircleMarkers(data = df_coords, 
                       lng = ~lng, 
                       lat = ~lat, 
                       radius = 5, 
                       color = ~state,
                       fillOpacity = 0.5,
                       popup = ~paste("Facility Name: ", facility_name, "<br>State: ", state, "<br>Zip Code: ", zip, "<br>Compound Released:",chemicals, "<br>Street Address:",Street_Address))

    # Show the map
    ny_map
    ```


## 3. Chronic Disease:
To choose the columns to work with, get a sample set of rows and clean the data  we used the following code:
```R
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
```

### To read the clean data for the web app:
```R

# Assuming 'subset_data' is a valid data frame with the required columns
subset_data <- readRDS("subset.rds")
location_topic_data <- readRDS("location_topic.rds")

# Get unique values of 'LocationAbbr' column
unique_locations <- unique(subset_data$LocationAbbr)
```
#### Shiny
```R
ui <- fluidPage(
  tabsetPanel(
    tabPanel("Disease Prevalence by State",
             selectInput("state", "Select State:", choices = unique_locations),
             plotOutput("chart1")),
    tabPanel("Disease Prevalence by Topic",
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
  
  # Regression-based Prediction
  output$predictionText <- renderText({
    # Filter data based on selected disease
    filtered_data <- subset_data[subset_data$Question == input$disease, ]
    
    # Prepare the data for regression
    regression_data <- filtered_data %>%
      group_by(LocationAbbr) %>%
      summarise(TotalCases =  n(), .groups = "keep") %>%
      select(TotalCases, everything())
    print(regression_data)
    # Remove rows with missing values
    regression_data <- na.omit(regression_data)
    
    # Split the data into training and testing sets
    set.seed(123) # For reproducibility
    train_index <- createDataPartition(regression_data$TotalCases, p = 0.7, list = FALSE)
    train_data <- regression_data[train_index, ]
    test_data <- regression_data[-train_index, ]
    
    # Select regression algorithm (e.g., linear regression)
    model <- train(TotalCases ~ ., data = train_data, method = "lm")
    
    # Make predictions on the testing data
    predicted <- predict(model, newdata = test_data)
    
    # Combine the predicted values with the actual values
    result <- cbind(test_data, PredictedCases = predicted)
    
    # Sort the predicted total cases in descending order
    sorted_result <- result[order(-result$PredictedCases), ]
    
    # Get the states with the most total cases
    top_states <- head(sorted_result$LocationAbbr, 5)
    
    # Prepare the output text
    prediction_text <- paste("States with Most Total Cases for", input$disease, ":")
    prediction_text <- paste(prediction_text, paste(top_states, collapse = ", "))
    
    # Return the prediction text
    prediction_text
  })
  
}

shinyApp(ui = ui, server = server)
```


# Authors

Lina Maatouk, Hildana Teklegiorgis, Eyoel Mulugeta
