setwd("/Users/hsiehhs7/Documents/Analyses for Phil/precipitation")
list.files()

library(rjson)

kalamazoo <- rjson::fromJSON(file = "Kalamazoo_County_metadata.json")
calhoun <- rjson::fromJSON(file = "Calhoun_County_metadata.json")
barry <- rjson::fromJSON(file = "Barry_County_metadata.json")

counties <- c(kalamazoo, calhoun, barry)

#kalamazoo$meta[[1]]$county
#kalamazoo$meta[[31]]$sids


#length(kalamazoo$meta)
#str(kalamazoo$meta)

station_summary <- function(station) {
  data.frame(
    sid = as.character(station$meta$sid),
    name = as.character(station$meta$name),
    longitude = as.numeric(station$meta$ll[1]),
    latitude = as.numeric(station$meta$ll[2])
  )
}

station_summary <- function(input) {
  data.frame(
    state = as.character(input$state),
    uid = as.character(input$uid),
    sid = as.character(input$sid),
    name = as.character(input$name),
    longitude = as.numeric(input$ll[1]),
    latitude = as.numeric(input$ll[2])
    
  )
}


result_list <- lapply(counties$meta, station_summary)

station_data <- do.call(rbind, result_list) %>%
  group_by(state, name, uid, longitude, latitude) %>%
  summarise(sid = paste(sid, collapse = ','))
tail(station_data)
head(station_data)

