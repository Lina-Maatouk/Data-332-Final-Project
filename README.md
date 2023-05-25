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





## 3. Chronic Disease in the US:



# Authors

Lina Maatouk, Hildana Teklegiorgis
