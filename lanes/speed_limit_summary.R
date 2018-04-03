library(odbc)
library(DBI)
library(dbplyr)
library(dplyr)
library(readr)

#connect to dbs
pg <- dbConnect(odbc::odbc(), "GISDB3")

lanes_query <- read_file("speed_limit_summary.sql")
res <- dbSendQuery(pg, lanes_query)
dbFetch(res)
dbClearResult(res)

#group by attributes and output geometries for map views
nw_db <- tbl(pg, "nw_tmc_speed_limit_ewkt")
nw_df <- as.data.frame(nw_db)

res <- dbSendQuery(pg, 'DROP VIEW tbuckley.nw_tmc_speed_limit_ewkt;')
dbFetch(res)
dbClearResult(res)

library(sf)
nw_sf <- st_as_sf(nw_df, wkt="shape_ewkt")

####group by 
nw_sf_speed_limit_all_vars <- nw_sf %>%
  group_by(rdstmc,
           speed,
           speedtyp,
           valdir,
           verified) %>% 
  summarise() %>%
  as.data.frame() %>%
  st_as_sf()

st_write(nw_sf_speed_limit_all_vars, "nw_sf_speed_limit_all_vars.gpkg", driver="GPKG")

nw_sf_speed_limit_simple <- nw_sf_speed_limit_all_vars %>%
  group_by(rdstmc) %>% 
  summarise(avg_speed=mean(speed),speed_count=n()) %>%
  as.data.frame() %>%
  st_as_sf()

st_write(nw_sf_speed_limit_simple, "nw_sf_speed_limit_simple.gpkg", driver="GPKG")
