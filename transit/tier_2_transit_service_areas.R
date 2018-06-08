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

operators <- c('VN','WH','CC','RV','PE',
               '3D','MA','ST','SR','SO',
               'UC','FS','VC','WC','AT',
               'BG', 'GF', 'SB')

library(gtfsr)
library(sf)
library(dplyr)
library(lubridate)
library(readr)

o511 <- read_csv("https://gist.githubusercontent.com/tbuckl/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")

o511 <- o511[o511$PrivateCode %in% c(operators),]

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

process_results <- lapply(download_results, 
                          FUN=function(x) {
                            try(gtfs_as_sf(x))}
                          )

is.error <- function(x) inherits(x, "try-error")
is.gtfs.obj <- function(x) inherits(x, "gtfs")
processed_success <- vapply(process_results, is.gtfs.obj, logical(1))
get.error.message <- function(x) {attr(x,"condition")$message}

merged_stops_sf <- try(merge_gtfsr_dfs(process_results[processed_success],"stops_sf"))
merged_stops_sf_weekday <- try(merge_gtfsr_dfs(process_results[processed_success],"stops_sf_weekday"))
merged_routes_sf <- try(merge_gtfsr_dfs(process_results[processed_success],"routes_sf"))
merged_routes_sf_weekday <- try(merge_gtfsr_dfs(process_results[processed_success],"routes_sf_weekday"))

st_write(merged_stops_sf,"merged_stops_sf.geojson",driver="GeoJSON")
st_write(merged_stops_sf_weekday,"merged_stops_sf_weekday.geojson",driver="GeoJSON")
st_write(merged_routes_sf,"merged_routes_sf.geojson",driver="GeoJSON")
st_write(merged_routes_sf_weekday,"merged_routes_sf_weekday.geojson",driver="GeoJSON")

st_write(planner_buffer(merged_stops_sf),
         "stops_sf_1_2.geojson",driver="GeoJSON")
st_write(planner_buffer(merged_stops_sf_weekday),
         "stops_sf_weekday_1_2.geojson",driver="GeoJSON")

## need to try one of the suggestions from pwramsey here:
# https://gis.stackexchange.com/questions/101639/postgis-st-buffer-breaks-because-of-no-forward-edges
# st_write(planner_buffer(merged_routes_sf,dist="q"),
#          "routes_sf_1_4.geojson",driver="GeoJSON")
# st_write(planner_buffer(merged_routes_sf_weekday,dist="q"),
#          "routes_sf_weekday_1_4.geojson",driver="GeoJSON")

