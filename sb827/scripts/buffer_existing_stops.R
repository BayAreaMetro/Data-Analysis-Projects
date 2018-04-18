library(sf)
library(dplyr)

setwd("~/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")

major_stops_827 <- st_read("major_stops_existing.geojson")
one_mile_in_meters <- 1609.344

major_stops_827_1_2_mile <- st_buffer(st_transform(major_stops_827,crs=26910),
                                      dist=(one_mile_in_meters/2))

st_write(major_stops_827_1_2_mile,"major_stops_1_2_mile.geojson")

#as requested by V
major_stops_827_1_4_mile <- st_buffer(st_transform(major_stops_827,crs=26910),
                                      dist=(one_mile_in_meters/4))
st_write(major_stops_827_1_2_mile,"major_stops_1_4_mile.geojson")
