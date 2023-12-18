setwd("/Users/hsiehhs7/Documents/Analyses for Phil/precipitation")
list.files()

library(rjson)
library(tidyverse)

albion <- rjson::fromJSON(file = "ACID_Albion.JSON")
ceresco <- rjson::fromJSON(file = "ACID_Ceresco.JSON")
burlington <- rjson::fromJSON(file = "precip_Burlington.JSON")
bc2 <- rjson::fromJSON(file = "ACID_BattleCreekKelloggAirpot_1895_1943.JSON")
bc <- rjson::fromJSON(file = "precip_BattleCreek5NW.JSON")
hastings <- rjson::fromJSON(file = "hastings_10_years_precip_data.JSON")

#sts <- list(albion, ceresco, burlington, bc2, bc, hastings)

station_summary <- function(station) {
  data.frame(
    sid = as.character(station$meta$sid),
    name = as.character(station$meta$name),
    longitude = as.numeric(station$meta$ll[1]),
    latitude = as.numeric(station$meta$ll[2])
  )
}

# Apply the function to the list of stations
result_list <- lapply(sts, station_summary)

# Combine the list elements into a data frame
station_data <- do.call(rbind, result_list) %>%
  group_by(name, longitude, latitude) %>%
  summarise(sid = paste(sid, collapse = ','))
station_data


# Print the resulting data frame
print(station_data)
