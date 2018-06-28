#output all operators stops and routes with summary
#devtools::install_github('BayAreaMetro/gtfsr')

library(gtfsr)
library(sf)
library(dplyr)
library(lubridate)
library(readr)
setwd("/home/shared/Data/transit")

#we need to use 2 api keys b/c of api rate limits
k511_1 <- ""
k511_2 <- ""

o511 <- read_csv("https://gist.githubusercontent.com/tbuckl/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")

Sys.setenv(APIKEY511 = k511_1)
api_key = Sys.getenv("APIKEY511")

download_results <- apply(o511[1:17,], 
                          1, 
                          function(x) try(get_mtc_511_gtfs(x['PrivateCode'],
                                                           api_key)))

Sys.setenv(APIKEY511 = k511_2)
api_key = Sys.getenv("APIKEY511")
download_results <- append(download_results,
                         apply(o511[18:34,], 
                               1, 
                               function(x) try(get_mtc_511_gtfs(x['PrivateCode'],
                                                                api_key))))


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

sf_routes <- lapply(sf_stops, 
                    FUN=function(x) {
                      try(gtfs_as_sf_routes(x))}
)

is.error <- function(x) inherits(x, "try-error")
is.gtfs.obj <- function(x) inherits(x, "gtfs")
ps_sf_stops <- vapply(sf_stops, is.gtfs.obj, logical(1))
ps_sf_routes <- vapply(sf_routes, is.gtfs.obj, logical(1))

get.error.message <- function(x) {attr(x,"condition")$message}

merged_stops_sf <- try(merge_gtfsr_dfs(sf_stops[ps_sf_stops],"stops_sf"))
merged_routes_sf <- try(merge_gtfsr_dfs(sf_routes[ps_sf_routes],"routes_sf"))

merged_stops_sf <- st_transform(merged_stops_sf, crs=26910)
merged_routes_sf <- st_transform(merged_routes_sf, crs=26910)

#######
##MANUAL FILL IN SR, YV, AB, FS, CE, AM, AY
#######

#pull AB (air bart) from 2014
#pull YV off 2014
#check on SR
routes_bus_2014 <- st_read("https://mtcdrive.box.com/shared/static/x75g63rsh3ogwojkioz7dp49o3imh0f4.geojson")

r2014 <- routes_bus_2014 %>% 
  filter(CPT_AGENCYID=="YV"|CPT_AGENCYID=="AB")

ay <- routes_bus_2014 %>% 
  filter(CPT_AGENCYID=="AY")

df1 <- st_as_sf(
  tibble(
    route_id = c("NA","NA"),
    agency_id = r2014$CPT_AGENCYID,
    agency_name = c("Air Bart (2014)","Vine (Yountville Trolley-2014)"),
    geometry = r2014$geometry
  )
)

df3 <- st_as_sf(
  tibble(
    route_id = c("NA"),
    agency_id = ay$CPT_AGENCYID,
    agency_name = c("American Canyon (2014)"),
    geometry = ay$geometry
  )
)

#####
#transitland
#####
#SR from transit.land (2018 source, unclear how tl got lines/routes, as direct link doesn't have them)
#https://transit.land/feed-registry/operators/o-9qbdx-santarosacitybus
sr <- st_read("https://transit.land/api/v1/routes.geojson?operated_by=o-9qbdx-santarosacitybus&per_page=false")

df2 <- st_as_sf(
  tibble(route_id = sr$name,
         agency_id = rep("SR",length(sr$name)),
         agency_name = rep("Santa Rosa (CityBus)",length(sr$name)),
         geometry = sr$geometry
  )
)

cc <- st_read("https://transit.land/api/v1/routes.geojson?operated_by=o-9q9p-countyconnection&per_page=false")
cc <- cc %>% filter(name=='250'|name=='ALAMOCR')

ai <- st_read("https://transit.land/api/v1/routes.geojson?operated_by=o-9q8zmw-angelislandtiburonferry&per_page=false")

fs <- st_read("https://transit.land/api/v1/routes.geojson?operated_by=o-9qc-fairfieldandsuisuntransit&per_page=false")
fs <- fs %>% filter(name=='7AT3'|name=='7BT'|name=='7AT')

tl1 <- do.call('rbind',list(fs,ai,cc))

df4 <- st_as_sf(
  tibble(route_id = tl1$name,
         agency_id = c('FS','FS','FS','AT','CC','CC'),
         agency_name = tl1$operated_by_name,
         geometry = tl1$geometry
  )
)

######
##commuter rail (mtc open data)
######
cr <- st_read("https://opendata.arcgis.com/datasets/a6512b81bd1b47a895bf18687e2600e6_0.geojson")
cr <- cr %>% filter(operator=="Altamont Commuter Rail"|operator=="Amtrak")

df5 <- st_as_sf(
  tibble(route_id = c(rep("ACE",9),c(rep('amtrak',15))),
         agency_id = c(rep('CE',9),rep('AM',15)),
         agency_name = cr$operator,
         geometry = cr$geometry
  )
)

#drop the gtfs routes for amtrak
merged_routes_sf <- merged_routes_sf %>% 
  filter(!agency_id=='AM' & !agency_name=="Capitol Corridor Joint Powers Authority")

####
##merge in
####

merged_routes_sf <- rbind(merged_routes_sf,df1)
merged_routes_sf <- rbind(merged_routes_sf,df2)
merged_routes_sf <- rbind(merged_routes_sf,df3)
merged_routes_sf <- rbind(merged_routes_sf,df4)
merged_routes_sf <- rbind(merged_routes_sf,df5)

######
##put route type on the data
#####

named_route_types_df <- tribble(
  ~route_type_id, ~vehicle_type,
  #--|--
  0,'Tram', 
  1,'Subway, Metro', 
  2,'Rail', 
  3,'Bus', 
  4,'Ferry', 
  5,'Cable car',
  6,'Gondola',
  7,'Funicular'
)

put_route_types_on_routes <- function(gtfsr_obj,named_route_types_df) {
  gtfsr_obj[['routes_df']] %>% 
    select(agency_id,route_id,route_type) %>%
    left_join(named_route_types_df, by=c("route_type"="route_type_id")) %>%
    select(agency_id,route_id,vehicle_type)
}

route_types_l <- lapply(download_results, 
                        FUN=function(x) {
                          try(put_route_types_on_routes(x,named_route_types_df))}
)

route_types_df <- bind_rows(route_types_l)

merged_routes_sf <- left_join(merged_routes_sf,route_types_df)

#this is necessary to clean up broken geometries for some providers
#installation dependencies can be difficult
#if the user has any issues installing the package
#they are urged to use the following website instead: http://mapshaper.org/
library(rmapshaper)
merged_routes_sf <- ms_simplify(merged_routes_sf, keep = 1, snap=TRUE)

#####
##Write to disk
#####

st_write(merged_stops_sf,"stops.geojson",driver="GeoJSON")
st_write(merged_routes_sf,"routes.geojson",driver="GeoJSON", delete_dsn = TRUE)

st_write(merged_stops_sf,"stops.shp",driver="ESRI Shapefile")
st_write(merged_routes_sf,"routes.shp",driver="ESRI Shapefile", delete_dsn = TRUE)

st_write(merged_stops_sf,"stops.gpkg",driver="GPKG")
st_write(merged_routes_sf,"routes.gpkg",driver="GPKG", delete_dsn = TRUE)

#####
##Summary to CSV
#####

df1 <- as.data.frame(merged_stops_sf) %>% 
  group_by(agency_name) %>% 
  summarise(all_stops = n())
df2 <- as.data.frame(merged_routes_sf) %>% 
  group_by(agency_name) %>% 
  summarise(all_routes = n())

summary_df <- left_join(df1,df2, by="agency_name")

write_csv(summary_df,"transit_summary.csv")

#compare to 2014 data

routes_bus_2014 <- st_read("https://mtcdrive.box.com/shared/static/x75g63rsh3ogwojkioz7dp49o3imh0f4.geojson")

routes_bus_2014_df <- routes_bus_2014
st_geometry(routes_bus_2014_df) <- NULL

merged_routes_df <- merged_routes_sf
st_geometry(merged_routes_df) <- NULL

summary_routes_18 <- merged_routes_df %>%
  as_tibble() %>%
  group_by(agency_id,agency_name) %>%
  summarise(count=n())

summary_routes_14 <- routes_bus_2014_df %>% 
  as_tibble() %>%
  rename(agency_id=CPT_AGENCYID) %>%
  group_by(agency_id) %>%
  summarise(count=n())

summary_14_18 <- full_join(summary_routes_14,
                           summary_routes_18, 
                           by="agency_id",
                           suffix=c(".14",".18"))

summary_14_18 <- summary_14_18 %>% select(agency_id,agency_name,count.14,count.18)

write_csv(summary_14_18,
          "summary_routes_14_18.csv")

