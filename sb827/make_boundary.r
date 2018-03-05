library(sf)
setwd("~/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")
major_stops_827_1_2_mile <- st_read("major_stops_827_1_2_mile.geojson")
stops_on_corridors_1_4_mile <- st_read("stops_on_corridors_1_4_mile.geojson")

major_stops_827_1_2_mile <- st_transform(major_stops_827_1_2_mile, crs=26910)
stops_on_corridors_1_4_mile <- st_transform(stops_on_corridors_1_4_mile, crs=26910)

major_stops_827_1_2_mile_sfg <- st_union(major_stops_827_1_2_mile$geometry)
stops_on_corridors_1_4_mile_sfg <- st_union(stops_on_corridors_1_4_mile$geometry)

sb827_feb_amendment_boundaries <- st_union(major_stops_827_1_2_mile_sfg,stops_on_corridors_1_4_mile_sfg)
st_write(st_transform(sb827_feb_amendment_boundaries, crs=4326),"sb827_feb_amendment_boundaries.geojson")

setwd("/Users/tbuck/Box/DataViz\ Projects/Data\ Analysis\ and\ Visualization/SB827")
st_write(sb827_feb_amendment_boundaries,"sb827_feb_amendment_boundaries.gpkg")
st_write(sb827_feb_amendment_boundaries,"sb827_feb_amendment_boundaries.shp")
