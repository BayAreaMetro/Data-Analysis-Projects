library(sf)
library(sp)
library(dplyr)
library(readr)
library(gtfsr)

summary_14_18 <- read_csv("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/summary_routes_14_18.csv")

operators_to_get <- summary_14_18 %>% 
  filter(is.na(count.18)) %>%
  pull(agency_id)

o511 <- read_csv("https://gist.githubusercontent.com/tbuckl/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")
o511 <- o511 %>% filter(PrivateCode %in% operators_to_get)

Sys.setenv(APIKEY511 = "APIKEY")
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

sf_stops <- lapply(download_results, 
                   FUN=function(x) {
                     try(gtfs_as_sf_stops(x))}
)

sf_routes <- lapply(sf_stops, 
                    FUN=function(x) {
                      try(gtfs_as_sf_routes(x))}
)

sf_stops_buffer <- lapply(sf_stops, 
                          FUN=function(x) {
                            try(gtfs_as_sf_stops_buffer(x))}
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

setwd("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/")

routes_fill_in_sf <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/routes_wh_cc.json")
routes_sf <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/routes.json")

routes_sf <- rbind(routes_sf,routes_fill_in_sf)

st_write(routes_sf,"routes.geojson")