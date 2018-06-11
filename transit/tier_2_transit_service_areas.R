# Points (stops), 
# then add 0.5mi buffer
# Lines (routes), 
# then add 0.25mi buffer
# then combine them
# Napa Valley Transit
# Livermore Amador Valley Transit Authority (LAVTA)
# Central Contra Costa Transit Authority (CCCTA)
# Dixon Readi-Ride
# Rio Vista Delta Breeze
# Petaluma Transit
# Eastern Contra Costa Transit Authority (Tri Delta Transit)
# Marin County Transit
# Solano County Transit (SolTrans)
# Santa Rosa City Bus
# Sonoma County Transit
# Union City Transit
# Fairfield-Suisun Transit
# Vacaville City Coach
# Western Contra Costa Transit Authority (WestCAT)
# Water Emergency Transportation Authority (WETA), including Alameda-Oakland and Vallejo Ferries

if (!require(devtools)) {
  install.packages('devtools')
}
devtools::install_github('BayAreaMetro/gtfsr')

operators <- c('VN','WH','CC','RV','PE',
               '3D','MA','ST','SR','SO',
               'UC','FS','VC','WC','AT',
               'BG', 'GF', 'SB')

library(gtfsr)
library(sf)
library(dplyr)
library(lubridate)
library(readr)
library(lwgeom)

o511 <- read_csv("https://gist.githubusercontent.com/tbuckl/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")

o511 <- o511[o511$PrivateCode %in% c(operators),]

Sys.setenv(APIKEY511 = "1754c626-9421-4bf4-8ac4-37cf69e71904")
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
ps_sf_stops <- vapply(process_results, is.gtfs.obj, logical(1))
ps_sf_stops_buffer <- vapply(process_results, is.gtfs.obj, logical(1))
ps_sf_routes <- vapply(process_results, is.gtfs.obj, logical(1))
ps_sf_routes_buffer <- vapply(process_results, is.gtfs.obj, logical(1))

get.error.message <- function(x) {attr(x,"condition")$message}

merged_stops_sf <- try(merge_gtfsr_dfs(sf_stops[ps_sf_stops],"stops_sf"))
merged_stops_sf_weekday <- try(merge_gtfsr_dfs(sf_stops_buffer[ps_sf_stops_buffer],"stops_sf_weekday"))
merged_routes_sf <- try(merge_gtfsr_dfs(sf_routes[ps_sf_routes],"routes_sf"))
merged_routes_sf_weekday <- try(merge_gtfsr_dfs(sf_routes_buffer[ps_sf_routes_buffer],"routes_sf_weekday"))

merged_stops_sf <- st_transform(merged_stops_sf, crs=26910)
merged_stops_sf_weekday <- st_transform(merged_stops_sf_weekday, crs=26910)
merged_routes_sf <- st_transform(merged_routes_sf, crs=26910)
merged_routes_sf_weekday <- st_transform(merged_routes_sf_weekday, crs=26910)

st_write(merged_stops_sf,"merged_stops_sf.shp",driver="ESRI Shapefile")
st_write(merged_stops_sf_weekday,"merged_stops_sf_weekday.shp",driver="ESRI Shapefile")
st_write(merged_routes_sf,"merged_routes_sf.shp",driver="ESRI Shapefile")
st_write(merged_routes_sf_weekday,"merged_routes_sf_weekday.shp",driver="ESRI Shapefile")

routes_sf_weekday_1_4_mile_buffer <- try(merge_gtfsr_dfs(process_results[processed_success],"routes_sf_weekday_1_4_mile_buffer"))
routes_sf_1_4_mile_buffer <- try(merge_gtfsr_dfs(process_results[processed_success],"routes_sf_1_4_mile_buffer"))
stops_sf_weekday_1_2_buffer <- try(merge_gtfsr_dfs(process_results[processed_success],"stops_sf_weekday_1_2_buffer"))
stops_sf_1_2_mile_buffer <- try(merge_gtfsr_dfs(process_results[processed_success],"stops_sf_1_2_mile_buffer"))

st_write(routes_sf_weekday_1_4_mile_buffer,"routes_sf_weekday_1_4_mile_buffer.shp",driver="ESRI Shapefile")
st_write(routes_sf_1_4_mile_buffer,"routes_sf_1_4_mile_buffer.shp",driver="ESRI Shapefile")
st_write(stops_sf_weekday_1_2_buffer,"stops_sf_weekday_1_2_buffer.shp",driver="ESRI Shapefile")
st_write(stops_sf_1_2_mile_buffer,"stops_sf_1_2_mile_buffer.shp",driver="ESRI Shapefile")

write_csv(as.data.frame(merged_stops_sf) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"merged_stops_sf_summary.csv")
write_csv(as.data.frame(merged_stops_sf_weekday) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"merged_stops_sf_weekday.csv")
write_csv(as.data.frame(merged_routes_sf) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"merged_routes_sf.csv")
write_csv(as.data.frame(merged_routes_sf_weekday) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"merged_routes_sf_weekday.csv")

write_csv(as.data.frame(stops_sf_weekday_1_2_buffer) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"stops_sf_weekday_1_2_buffer.csv")
write_csv(as.data.frame(stops_sf_1_2_mile_buffer) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"stops_sf_1_2_mile_buffer.csv")
write_csv(as.data.frame(routes_sf_weekday_1_4_mile_buffer) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"routes_sf_weekday_1_4_mile_buffer.csv")
write_csv(as.data.frame(routes_sf_1_4_mile_buffer) %>% 
            group_by(agency_name) %>% 
            summarise(count = n()),"routes_sf_1_4_mile_buffer.csv")
