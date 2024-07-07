#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

ui <- fluidPage(
  titlePanel("My Shiny App"),
  
 
    mainPanel(
      tabsetPanel(
        tabPanel("About", 
                 h2("About"),
                 p("The purpose of this app is to download and explore the weather in the place you selected ."),
                 p("Data Source: ", a(href = "https://api.openweathermap.org", "Data Source Link")),
                 p("OpenWeatherMap is a service that provides global weather data, including current weather, forecasts, and historical data, through its robust API. It offers a variety of data types, such as temperature, humidity, wind speed, and precipitation, which can be integrated into web and mobile applications. The platform sources data from a combination of meteorological broadcast services, weather stations, and global satellite data. OpenWeatherMap is widely used by developers, businesses, and researchers for its comprehensive and accessible weather information.."),
                 p("Tab Information:"),
                 p("  Data Download:Allow the user to specify changes to your API querying functions and return data"),
                 p("  Data Exploration:Allow the user to choose variables/combinations of variables that are summarized via numerical and graphical summaries"),
        ),
        tabPanel("Data Download", 
                 h2("Data Download"),
                 textInput("apiKey", "API Key:"),
                 textInput("endpoint", "Endpoint:", value = "forecast"),
                 textInput("city", "City:"),
                 actionButton("fetchData", "Fetch Data"),
                 br(), br(),
                 tableOutput("dataTable"),
                 h3("Subset Data"),
                 textInput("subsetRows", "Rows to Keep (comma-separated, e.g., 1,2,3):"),
                 textInput("subsetCols", "Columns to Keep (comma-separated, e.g., temp,humidity):"),
                 actionButton("subsetData", "Subset Data"),
                 br(), br(),
                 tableOutput("subsetTable"),
                 br(),
                 downloadButton("downloadData", "Download Data")
        )
       
        
      )
    )
  )
