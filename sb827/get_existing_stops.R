library(sf)
library(dplyr)

setwd("~/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")

major_stops_url <- "https://opendata.arcgis.com/datasets/561dc5b42fa9451b95faf615a3054260_0.geojson"
major_stops_pba <- st_read(major_stops_url)

valid_status = c('Existing', 'Existing/Built')

major_stops_827 <- major_stops_pba %>% 
  filter(major_stops_pba$project_status %in% valid_status)

st_write(major_stops_827,"major_stops_existing.geojson")