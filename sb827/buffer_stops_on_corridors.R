library(sf)
library(dplyr)

setwd("~/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")

stops_on_corridors <- st_read("bus_stops_on_high_frequency_corridors.geojson")
one_mile_in_meters <- 1609.344

stops_on_corridors_1_4_mile <- st_buffer(st_transform(stops_on_corridors,
                                                      crs=26910),
                                         dist=(one_mile_in_meters/4))
stops_on_corridors_1_4_mile <- st_transform(stops_on_corridors_1_4_mile,crs=4326)

st_write(stops_on_corridors_1_4_mile,"bus_stops_on_high_frequency_corridors_1_4_mile.geojson")

#as requested by VS
stops_on_corridors_1_2_mile <- st_buffer(st_transform(stops_on_corridors,
                                                      crs=26910),
                                         dist=(one_mile_in_meters/2))

stops_on_corridors_1_2_mile <- st_transform(stops_on_corridors_1_4_mile,crs=4326)
st_write(stops_on_corridors_1_2_mile,"bus_stops_on_high_frequency_corridors_1_2_mile.geojson")
