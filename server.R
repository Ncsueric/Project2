#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(tidyr)

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
  
  weather_data <- weather_data|>
    select(real_date,temp,feels_like,pressure,sea_level,humidity,description,pod)
  
  names(weather_data) <- c("Date_and_time", "Temperature","Feels_like","Pressure","Atmospheric_pressure_on_the_sea_level","Humidity","Weather_Condition_within_the_Group","Day_or_Night")
  
  return(weather_data)
}

server <- function(input, output, session) {
  # Reactive values to store data
  weatherData <- reactiveVal()
  subsetData <- reactiveVal()
  
  # Fetch data event
  observeEvent(input$fetchData, {
    apiKey <- input$apiKey
    endpoint <- input$endpoint
    city <- input$city
    
    data <- query(apiKey, endpoint, city)
    weatherData(data)
    subsetData(data)
    
    # Update selectInput choices based on the queried dataset
    updateSelectInput(session, "xvar", choices = names(data))
    updateSelectInput(session, "yvar", choices = names(data))
    updateSelectInput(session, "facetVar", choices = c("None", names(data)))
  })
  
  # Subset data event
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
  
  # Render fetched data table
  output$dataTable <- renderTable({
    weatherData()
  })
  
  # Render subset data table
  output$subsetTable <- renderTable({
    subsetData()
  })
  
  # Download subset data
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("weather_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(subsetData(), file, row.names = FALSE)
    }
  )
  
  # Generate the plot based on user inputs
  output$plot <- renderPlot({
    data <- weatherData()
    req(data)
    xvar <- input$xvar
    yvar <- input$yvar
    facetVar <- input$facetVar
    plotType <- input$plotType
    
    p <- ggplot(data, aes_string(x = xvar, y = yvar)) 
    
    if (plotType == "Scatterplot") {
      p <- p + geom_point()
    } else if (plotType == "Boxplot") {
      p <- p + geom_boxplot()+geom_jitter(width = 0.2, alpha = 0.3)
    } else if (plotType == "Lineplot") {
      p <- p + geom_line()
    }
    
    if (facetVar != "None") {
      p <- p + facet_wrap(as.formula(paste("~", facetVar)))
    }
    
    print(p)
  })
  
  # Generate the numerical summary based on user inputs
  output$summary <- renderPrint({
    data <- weatherData()
    req(data)
    xvar <- input$xvar
    yvar <- input$yvar
    summaryType <- input$summaryType
    
    summary_table <- data %>%
      group_by(.data[[xvar]]) %>%
      summarise(
        Mean = mean(.data[[yvar]], na.rm = TRUE),
        Median = median(.data[[yvar]], na.rm = TRUE),
        Min = min(.data[[yvar]], na.rm = TRUE),
        Max = max(.data[[yvar]], na.rm = TRUE),
        SD = sd(.data[[yvar]], na.rm = TRUE)
      ) %>%
      pivot_longer(cols = -1, names_to = "Statistic", values_to = "Value") %>%
      pivot_wider(names_from = .data[[xvar]], values_from = Value)
    
    print(summary_table)
  })
}

