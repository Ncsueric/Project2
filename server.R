#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(httr)
library(jsonlite)
library(dplyr)

# Function to query weather data
query <- function(apiKey, endpoint, city) {
  baseURL <- "https://api.openweathermap.org/data/2.5/"
  fullURL <- paste0(baseURL, endpoint, "?q=", city, "&appid=", apiKey)
  
  response <- GET(fullURL)
  data <- fromJSON(content(response, "text"))
  
  forecasts <- data$list
  main_df <- bind_rows(forecasts$main)
  weather_df <- bind_rows(forecasts$weather)
  sys_df <- bind_rows(forecasts$sys)
  other_fields <- data.frame(
    dt = forecasts$dt
  )
  
  other_fields$real_date <- as.POSIXct(other_fields$dt, origin = "1970-01-01", tz = "UTC")
  
  weather_data <- bind_cols(other_fields, main_df, weather_df, sys_df)
  return(weather_data)
}

server <- function(input, output) {
 
   #for Data Download
  
  weatherData <- reactiveVal()
  subsetData <- reactiveVal()
  
  observeEvent(input$fetchData, {
    apiKey <- input$apiKey
    endpoint <- input$endpoint
    city <- input$city
    
    data <- query(apiKey, endpoint, city)
    weatherData(data)
    subsetData(data)
  })
  
  observeEvent(input$subsetData, {
    data <- weatherData()
    rows <- as.integer(unlist(strsplit(input$subsetRows, ",")))
    cols <- unlist(strsplit(input$subsetCols, ","))
    
    if (length(rows) > 0) {
      data <- data[rows, ]
    }
    if (length(cols) > 0) {
      data <- data[, cols, drop = FALSE]
    }
    
    subsetData(data)
  })
  
  output$dataTable <- renderTable({
    weatherData()
  })
  
  output$subsetTable <- renderTable({
    subsetData()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("weather_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(subsetData(), file, row.names = FALSE)
    }
  )
  
}