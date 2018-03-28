library(odbc)
library(DBI)
library(dbplyr)
library(dplyr)
library(readr)

#connect to dbs
rs <- dbConnect(odbc::odbc(), "Redshift")
pg <- dbConnect(odbc::odbc(), "GISDB3")

lanes_query <- read_file("lanes_summary.sql")
res <- dbSendQuery(pg, lanes_query)
dbFetch(res)
dbClearResult(res)

#group by attributes and output geometries for map views
nw_db <- tbl(pg, "nw_lanes_ops_ewkt")
nw_df <- as.data.frame(nw_db)

res <- dbSendQuery(pg, 'DROP VIEW tbuckley.nw_lanes_ops_ewkt;')
dbFetch(res)
dbClearResult(res)

library(sf)
nw_sf <- st_as_sf(nw_df, wkt="shape_ewkt")

####group by 
nw_sf_sum <- nw_sf %>%
  group_by(frc,name,shieldnum,freeway,tollrd,oneway,lanes,
                      ramp,fow,kph,speedcat,partstruc,dividertyp,
                      direction,lanetyp,singoc,minvehoc,payment,
                      laneend,feattyp) %>% 
  summarise(geog = st_union(shape_ewkt), nw_minutes_sum = sum(minutes)) 

#need to determine the necessary argument to pass "-nlt=MULTILINESTRING
#st_write(nw_sf_sum, "nw_sum.gdb", driver="GDB")

nw_sf_sum <- nw_sf_sum_backup

st_write(nw_sf_sum, "nw_sum.gpkg", driver="GPKG")

nw_df_sum <- as.data.frame(nw_sf_sum)

nw_df_sum$shape_as_ewkt = st_as_text(nw_df_sum$shape_ewkt)

library(dplyr)
nw_df_sum <- nw_df_sum %>% select(-c(geog,shape_ewkt))

###sample oakland
sample_bbox_url <- "https://gist.githubusercontent.com/tibbl35/14b07e049cf8c72d6fabef996de7cbde/raw/d56c8a7d1e913bccf2c4a92470bf5da26afa1554/downtown_alameda.geojson"
sample_bbox_sf <- st_read(sample_bbox_url)

sample_bbox_sf <- st_transform(sample_bbox_sf, crs=3857)

(mat = st_within(nw_sf_sum, sample_bbox_sf, sparse = FALSE))
v1 <- apply(mat, 1, any)

nw_sf_sum_sample_oakland <- nw_sf_sum[v1,]

st_write(nw_sf_sum_sample_oakland, "nw_sf_sum_sample_oakland.gpkg", driver="GPKG")

###sample san ramon
sample_bbox_url <- "https://gist.githubusercontent.com/tibbl35/42071191f4abf401449ec0d12e406be6/raw/62fdd3905e1356333b8e3232f097d3a06eabe783/san_ramon_livermore_sample_bbox.geojson"
sample_bbox_sf <- st_read(sample_bbox_url)

sample_bbox_sf <- st_transform(sample_bbox_sf, crs=3857)

(mat = st_within(nw_sf_sum, sample_bbox_sf, sparse = FALSE))
v1 <- apply(mat, 1, any)

nw_sf_sum_sample_san_ramon <- nw_sf_sum[v1,]

st_write(nw_sf_sum_sample_san_ramon, "nw_sf_sum_sample_san_ramon.gpkg", driver="GPKG")





###write to redshift
###
#this threw an error about data types
#need to figure out how to write the table to rs with longer character string for ewkt
#probably just pass in types for each column with the ewkt as something longer
# DBI::dbWriteTable(conn = rs,
#                   name = "traffic.nw_lanes_summary",
#                   value = nw_df_sum)

###join with tmcid

