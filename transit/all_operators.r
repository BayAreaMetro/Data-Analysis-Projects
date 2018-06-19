#output all operators stops and routes with summary
devtools::install_github('BayAreaMetro/gtfsr')

library(gtfsr)
library(sf)
library(dplyr)
library(lubridate)
library(readr)

o511 <- read_csv("https://gist.githubusercontent.com/tbuckl/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")

Sys.setenv(APIKEY511 = "YOURKEY")
api_key = Sys.getenv("APIKEY511")

download_results <- apply(o511, 1, function(x) try(get_mtc_511_gtfs(x['PrivateCode'],api_key)))
is.error <- function(x) inherits(x, "try-error")
is.gtfs.obj <- function(x) inherits(x, "gtfs")
imported_success <- !vapply(download_results, is.error, logical(1))
get.error.message <- function(x) {attr(x,"condition")$message}
import_error_message <- vapply(download_results[!imported_success], get.error.message, "")

o511['downloaded'] <- TRUE
o511['imported'] <- imported_success
o511['import_error_message'] <- ""
o511[!imported_success,'error_message1'] <- import_error_message

#if necessary, can name the list of downloads for easier access
#names(download_results) <- o511$ShortName

#save all objects to disk
save(download_results, file = "gtfs511_downloads.RData")

sf_stops <- lapply(download_results, 
                   FUN=function(x) {
                     try(gtfs_as_sf_stops(x))}
)

sf_stops_buffer <- lapply(sf_stops, 
                          FUN=function(x) {
                            try(gtfs_as_sf_stops_buffer(x))}
)

sf_routes <- lapply(sf_stops_buffer, 
                    FUN=function(x) {
                      try(gtfs_as_sf_routes(x))}
)

sf_routes_buffer <- lapply(sf_routes, 
                           FUN=function(x) {
                             try(gtfs_as_sf_routes_buffer(x))}
)

is.error <- function(x) inherits(x, "try-error")
is.gtfs.obj <- function(x) inherits(x, "gtfs")
ps_sf_stops <- vapply(sf_stops, is.gtfs.obj, logical(1))
ps_sf_stops_buffer <- vapply(sf_stops_buffer, is.gtfs.obj, logical(1))
ps_sf_routes <- vapply(sf_routes, is.gtfs.obj, logical(1))
ps_sf_routes_buffer <- vapply(sf_routes_buffer, is.gtfs.obj, logical(1))

get.error.message <- function(x) {attr(x,"condition")$message}

merged_stops_sf <- try(merge_gtfsr_dfs(sf_stops[ps_sf_stops],"stops_sf"))
merged_stops_sf_weekday <- try(merge_gtfsr_dfs(sf_stops_buffer[ps_sf_stops],"stops_sf_weekday"))
merged_routes_sf <- try(merge_gtfsr_dfs(sf_routes[ps_sf_routes],"routes_sf"))
merged_routes_sf_weekday <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_routes],"routes_sf_weekday"))

merged_stops_sf <- st_transform(merged_stops_sf, crs=26910)
merged_stops_sf_weekday <- st_transform(merged_stops_sf_weekday, crs=26910)
merged_routes_sf <- st_transform(merged_routes_sf, crs=26910)
merged_routes_sf_weekday <- st_transform(merged_routes_sf_weekday, crs=26910)

routes_sf_weekday_1_4_mile_buffer <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_routes_buffer],"routes_sf_weekday_1_4_mile_buffer"))
routes_sf_1_4_mile_buffer <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_routes_buffer],"routes_sf_1_4_mile_buffer"))
stops_sf_weekday_1_2_buffer <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_stops_buffer],"stops_sf_weekday_1_2_buffer"))
stops_sf_1_2_mile_buffer <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_stops_buffer],"stops_sf_1_2_mile_buffer"))

#####
##Write to disk
#####

st_write(merged_stops_sf,"stops.geojson",driver="GeoJSON")
st_write(merged_stops_sf_weekday,"stops_weekday.geojson",driver="GeoJSON")
st_write(merged_routes_sf,"routes.geojson",driver="GeoJSON")
st_write(merged_routes_sf_weekday,"routes_weekday.geojson",driver="GeoJSON")

st_write(merged_stops_sf,"stops.shp",driver="ESRI Shapefile")
st_write(merged_stops_sf_weekday,"stops_weekday.shp",driver="ESRI Shapefile")
st_write(merged_routes_sf,"routes.shp",driver="ESRI Shapefile")
st_write(merged_routes_sf_weekday,"routes_weekday.shp",driver="ESRI Shapefile")

#st_write(routes_sf_weekday_1_4_mile_buffer,"routes_sf_weekday_1_4_mile_buffer.shp",driver="ESRI Shapefile")
#st_write(routes_sf_1_4_mile_buffer,"routes_sf_1_4_mile_buffer.shp",driver="ESRI Shapefile")
#st_write(stops_sf_weekday_1_2_buffer,"stops_sf_weekday_1_2_buffer.shp",driver="ESRI Shapefile")
#st_write(stops_sf_1_2_mile_buffer,"stops_sf_1_2_mile_buffer.shp",driver="ESRI Shapefile")

#####
##Summary to CSV
#####

df1 <- as.data.frame(merged_stops_sf) %>% 
            group_by(agency_name) %>% 
            summarise(weekday = n())
df2 <- as.data.frame(merged_stops_sf_weekday) %>% 
            group_by(agency_name) %>% 
            summarise(weekday_stops = n())
df3 <- as.data.frame(merged_routes_sf) %>% 
            group_by(agency_name) %>% 
            summarise(routes = n())
df4 <- as.data.frame(merged_routes_sf_weekday) %>% 
            group_by(agency_name) %>% 
            summarise(weekday_routes = n())

summary_df <- left_join(df1,df2, by="agency_name") %>% 
  left_join(df3, by="agency_name") %>% 
  left_join(df4, by="agency_name")

write_csv(summary_df,"transit_summary.csv")



