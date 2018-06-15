library(bikedata)
library(RSQLite)
library(dplyr)
library(magrittr)
library(readr)
library(stringr)
library(uuid)
library(sp)


june_station_cities <- read_csv("/home/shared/bikedata/data/june_station_cities.csv")

data_dir <- "/home/shared/bikedata/bay_area_only2"
#dl_bikedata (city = 'sf', data_dir = data_dir)
bikedb <- file.path (data_dir, 'sfdb')
#store_bikedata (data_dir = data_dir, city = 'sf', bikedb = bikedb)

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

xlims_sf <- range(stations_bd$lon, na.rm = TRUE)
ylims_sf <- range(stations_bd$lat, na.rm = TRUE)
ex <- 0.1
xlims_sf <- xlims_sf + c (-ex, ex) * diff (xlims_sf)
ylims_sf <- ylims_sf + c (-ex, ex) * diff (ylims_sf)

x1 <- stations_bd$lon [match (ntrips$start_station_id, stations_bd$stn_id)]
y1 <- stations_bd$lat [match (ntrips$start_station_id, stations_bd$stn_id)]
x2 <- stations_bd$lon [match (ntrips$end_station_id, stations_bd$stn_id)]
y2 <- stations_bd$lat [match (ntrips$end_station_id, stations_bd$stn_id)]

plot (stations_bd$lon, stations_bd$lat, xlim = xlims_sf, ylim = ylims_sf)

cols <- rainbow (100)
nt <- ceiling (ntrips$numtrips * 100 / max (ntrips$numtrips))
for (i in seq (x1))
  lines (c (x1 [i], x2 [i]), c (y1 [i], y2 [i]), col = cols [nt [i]],
         lwd = ntrips$numtrips [i] * 10 / max (ntrips$numtrips))

ntrips_full <- left_join(ntrips,
                     stations_bd,
                     by=c("start_station_id"="stn_id")) %>%
  left_join(stations_bd,by=c("end_station_id"="stn_id"))

ntrips_full %>% group_by(start_station_id,end_station_id) %>% 
  summarize(m = mean(attr_data)) %>% st_cast("LINESTRING")
  
    st_point() %>% st_cast("LINESTRING") %>% 
  plot()

  
matrix(c(lon.x,lat.x,lon.y,lat.y),nrow=2,ncol=2)

ntrips_full[c(lon.x,lat.x,lon.y,lat.y)]

make_linestring <- function(x1,y1,x2,y2) {
  m1 <- matrix(c(x1,
           y1,
           x2,
           y2),nrow=2,ncol=2)
  print(m1)
  ls1 <- st_linestring(m1)
  print(ls1)
  return(ls1)
}

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


west <- ntrips_full_sf2 %>% filter(region == "west") %>%
  select(name.x,name.y,numtrips) %>%
  filter(numtrips>100) %>%
  arrange(desc(numtrips))

east <- ntrips_full_sf2 %>% filter(region == "east") %>%
  select(name.x,name.y,numtrips) %>%
  filter(numtrips>1) %>%
  arrange(desc(numtrips))

south <- ntrips_full_sf2 %>% filter(region == "south") %>%
  select(name.x,name.y,numtrips) %>%
  filter(numtrips>1) %>%
  arrange(desc(numtrips)) 


st_write(west,"west.geojson")

st_write(east,"east.geojson")

st_write(south,"south.geojson")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="west"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="west"], na.rm = TRUE)

tmap::tm_shape (west, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 200, 400, 600, 800, 1000, Inf),
                  legend.lwd.show = FALSE, scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5)

tmap::save_tmap (filename = "west_bay_map.png")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="east"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="east"], na.rm = TRUE)

tmap::tm_shape (east, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 50, 100, 200, 400, 1000, Inf),
                  legend.lwd.show = FALSE, scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5)

tmap::save_tmap (filename = "east_bay_map.png")

xlims <- range(ntrips_full_sf2$lon.x[ntrips_full_sf2$region=="south"], na.rm = TRUE)
ylims <- range(ntrips_full_sf2$lat.x[ntrips_full_sf2$region=="south"], na.rm = TRUE)

tm <- tmap::tm_shape (south, xlim = xlims, ylim = ylims, is.master=TRUE) + 
  tmap::tm_lines (col="numtrips", lwd="numtrips", title.col = "Number of trips",
                  breaks = c(0, 200, 400, 600, 800, 1000, Inf),
                  legend.lwd.show = FALSE, scale = 5) + 
  tmap::tm_layout (bg.color="black", legend.position = c ("right", "bottom"),
                   legend.bg.color = "white", legend.bg.alpha = 0.5)

tmap::save_tmap (filename = "south_bay_map.png")

#use tmap_mode("view") to make interactive maps. 