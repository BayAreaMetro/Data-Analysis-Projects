library(gtfsr)
library(sf)
library(mapview)
library(dplyr)

setwd("~/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")

hf_routes_url <- "https://opendata.arcgis.com/datasets/6b9d4597489d451187f49525f1a7b6cf_0.geojson"
hf_routes_sf <- st_read(hf_routes_url)
hf_routes_df <- hf_routes_sf[,c('agency','route_id')]
st_geometry(hf_routes_df) <- NULL

library(readr)

#read 511 orgs list
o511 <- read_csv("https://gist.githubusercontent.com/tibbl35/d49fa2c220733b0072fc7c59e0ac412b/raw/cff45d8c8dd2ea951b83c0be729abe72f35b13f7/511_orgs.csv")
agency_ids <- filter(o511, PrivateCode %in% hf_routes_df$agency) %>% select(PrivateCode)
agency_ids <- agency_ids[[1]]

#Sys.setenv(APIKEY511 = "YOUR API KEY")
api_key = Sys.getenv("APIKEY511")



get_service_id <- function(df_calendar) {
  print(df_calendar)
  dfc <- df_calendar[df_calendar['monday']==1 &
                    df_calendar['tuesday']==1 &
                    df_calendar['wednesday']==1 &
                    df_calendar['thursday']==1 &
                    df_calendar['friday']==1,]
  service_ids <- dfc$service_id
  print(dfc)
  return(service_ids)
}

list_of_sf <- list()

for(agency_id1 in agency_ids) {
  zip_request_url = paste0('http://api.511.org/transit/datafeeds?api_key=',
                           api_key,
                           '&operator_id=',
                           agency_id1)
  
  g1 <- zip_request_url %>% import_gtfs
  print("something")
  
  service_id1 <- get_service_id(g1$calendar_df)
  print(service_id1)
  if(dim(g1$stops_df)[1]>0) {
    hf_routes_df_agency <- hf_routes_df %>% filter(agency==agency_id1)
    route_ids <- hf_routes_df_agency$route_id
    
    trips_hf <- g1$trips_df %>%
      filter(route_id %in% route_ids,
             service_id %in% service_id1)
    print(dim(trips_hf))
    stop_times_hf <- g1$stop_times_df %>% 
      filter(trip_id %in% trips_hf$trip_id)
    
    stops_hf <- g1$stops_df %>% 
      filter(stop_id %in% stop_times_hf$stop_id)
    
    print(dim(stops_hf))
    list_of_sf[[agency_id1]] <- stops_df_as_sf(stops_hf)
    
  } else
  {
    print("no stops for:")
    print(agency_id1)
  }
}

stops_on_corridors <- do.call("rbind", list_of_sf)

major_stops_url <- "https://opendata.arcgis.com/datasets/561dc5b42fa9451b95faf615a3054260_0.geojson"
major_stops_pba <- st_read(major_stops_url)

valid_status = c('Existing', 'Existing/Built')

major_stops_827 <- major_stops_pba %>% 
  filter(major_stops$project_status %in% valid_status)

st_write(major_stops_827,"major_stops.geojson")
st_write(stops_on_corridors,"stops_on_high_frequency_corridors.geojson")

one_mile_in_meters <- 1609.344

major_stops_827_1_2_mile <- st_buffer(st_transform(major_stops_827,crs=26910),
          dist=(one_mile_in_meters/2))

stops_on_corridors_1_4_mile <- st_buffer(st_transform(stops_on_corridors,
                                         crs=26910),
                                         dist=(one_mile_in_meters/4))

major_stops_827_1_2_mile <- st_transform(major_stops_827_1_2_mile,crs=4326)
stops_on_corridors_1_4_mile <- st_transform(stops_on_corridors_1_4_mile,crs=4326)

st_write(major_stops_827_1_2_mile,"major_stops_1_2_mile.geojson")
st_write(stops_on_corridors_1_4_mile,"stops_on_high_frequency_corridors_1_4_mile.geojson")




