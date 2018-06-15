library(bikedata)
library(RSQLite)
library(dplyr)
library (magrittr)
library(readr)
library(stringr)
library(uuid)
library(sp)

june_station_cities <- read_csv("/home/shared/bikedata/data/june_station_cities.csv")

data_dir <- "/home/shared/bikedata/bay_area_only2"
#dl_bikedata (city = 'sf', data_dir = data_dir)
bikedb <- file.path (data_dir, 'sfdb')
#store_bikedata (data_dir = data_dir, city = 'sf', bikedb = bikedb)

ntrips <- bike_tripmat (bikedb = bikedb, city = 'sf', long = TRUE)

### check stations
con <- dbConnect(RSQLite::SQLite(), bikedb)
stations_bd <- tbl(con, "stations") %>% as_tibble()

dbDisconnect(con)

#fix inverted lat/long
stations_bd <- stations_bd %>% 
  rename(lat = longitude) %>% 
  rename(lon = latitude) 

stations_bd$lon <- as.numeric(stations_bd$lon)
stations_bd$lat <- as.numeric(stations_bd$lat)

ntrips_full <- left_join(ntrips,
                     stations_bd,
                     by=c("start_station_id"="stn_id")) %>%
  left_join(stations_bd,by=c("end_station_id"="stn_id"))


latlng_m <- ntrips_full[c('lon.x','lat.x','lon.y','lat.y')]

#from https://gis.stackexchange.com/questions/196029/how-to-efficiently-convert-origin-destination-coordinates-into-lines-in-r/196033
odf <- sp::SpatialLines(apply(latlng_m, 1, function(r) {
  sp::Lines(list(sp::Line(cbind(r[c(1,3)], r[c(2,4)]))), uuid::UUIDgenerate())
}))

odf_sf <- st_as_sf(odf)

ntrips_full_sf <- st_sf(ntrips_full,odf_sf$geometry)

regions <- tibble(City=unique(june_station_cities$City),
                  region=c("east","east","east","south","west"))

june_station_cities <- left_join(june_station_cities,regions)

ntrips_full_sf$station_id <- as.integer(str_replace(ntrips_full_sf$start_station_id, "sf", ""))

ntrips_full_sf2 <- left_join(ntrips_full_sf,
                            june_station_cities)

ntrips_full_sf2 <- ntrips_full_sf2 %>% 
  rename(origin=name.x) %>% 
  rename(destination=name.y)

west <- ntrips_full_sf2 %>% filter(region == "west") %>%
  select(origin,destination,numtrips) %>%
  filter(numtrips>100) %>%
  arrange(desc(numtrips))

east <- ntrips_full_sf2 %>% filter(region == "east") %>%
  select(origin,destination,numtrips) %>%
  filter(numtrips>1) %>%
  arrange(desc(numtrips))

south <- ntrips_full_sf2 %>% filter(region == "south") %>%
  select(origin,destination,numtrips) %>%
  filter(numtrips>1) %>%
  arrange(desc(numtrips)) 

# st_write(west,"west.geojson")
# 
# st_write(east,"east.geojson")
# 
# st_write(south,"south.geojson")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="west"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="west"], na.rm = TRUE)

tm1 <- tmap::tm_shape (west, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 200, 400, 600, 800, 1000, Inf),
                  legend.lwd.show = FALSE, scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5)  +
  tm_view(basemaps = leaflet::providers$Stamen.Toner)

tmap::tmap_save (tm1, filename = "west_bay_map.png")
tmap::tmap_save (tm1, filename = "west_bay_map.html")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="east"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="east"], na.rm = TRUE)

tmap::tm_shape (east, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 50, 100, 200, 400, 1000, Inf),
                  legend.lwd.show = FALSE, 
                  popup.vars = TRUE,
                  scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5) +
  tm_view(basemaps = leaflet::providers$Stamen.Toner)

tmap::tmap_save (tm1, filename = "east_bay_map.png")
tmap::tmap_save (tm1, filename = "east_bay_map.html")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="south"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="south"], na.rm = TRUE)

tm1 <- tmap::tm_shape (south, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 200, 400, 600, 800, 1000, Inf),
                  legend.lwd.show = FALSE, 
                  popup.vars = TRUE,
                  scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5) +
  tm_view(basemaps = leaflet::providers$Stamen.Toner)

tmap::tmap_save (tm1, filename = "south_bay_map.png")
tmap::tmap_save (tm1, filename = "south_bay_map.html")

#use tmap_mode("view") to make interactive maps.
