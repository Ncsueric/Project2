# project2

OpenWeatherMap is a service that provides global weather data, including current weather, forecasts, and historical data, through its robust API. It offers a variety of data types, such as temperature, humidity, wind speed, and precipitation, which can be integrated into web and mobile applications. The platform sources data from a combination of meteorological broadcast services, weather stations, and global satellite data. OpenWeatherMap is widely used by developers, businesses, and researchers for its comprehensive and accessible weather information.

The purpose of this app is to download and explore the weather data in the place you selected from OpenWeatherMap

We provided hourly forecast for 4 days (96 timestamps), variables including:Date and time/Temperature/Feels like/Pressure/Atmospheric pressure on the sea level/Humidity/Weather Condition within the Group/Day or Night".

Please install packages needed below to run the app.

```{r}

library(shiny) 
library(httr) 
library(jsonlite) 
library(dplyr) 
library(ggplot2)
library(tidyr)

```

Please copy the code below and run it in your R studio

```{r}
shiny::runGitHub(repo = "Project2", username = "Ncsueric")
```

**Enjoy it!**
