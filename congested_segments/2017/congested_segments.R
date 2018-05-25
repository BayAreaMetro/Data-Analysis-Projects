library(DBI)
library(RPostgreSQL)
library(sf)
library(dplyr)

cs_18 <- readxl::read_excel("data/WeekdayCongestedSegmentsList_2017_v2.xlsx")

#connect to the db
db3_cred <- jsonlite::read_json("~/credentials/tbuckley_gisdb3.json")

db3 <- dbConnect(RPostgreSQL::PostgreSQL(),
                 dbname = db3_cred['database'], 
                 host = db3_cred['host'], 
                 port = 5432,
                 user = db3_cred['username'],
                 password = db3_cred['password'])

tmc_ids1 <- cs_18$`TMC ID`

tmc_query <- readr::read_file("congested_segments.sql")

tmc_query <- glue::glue_sql(tmc_query,
                            tmc_ids = tmc_ids1,
                            .con=db3)

dat <- dbGetQuery(db3, tmc_query)

df3 <- st_as_sf(dat, wkt = "geom", crs = 3857)

cs18_sf <- inner_join(df3,cs_18,by=c("tmcid"="TMC ID"))

cs18_limits <- cs18_sf %>% 
  group_by(LIMITS,startTime,endTime,`Segment Delay  (Veh-Hrs)`,Rank,`length (Miles)`) %>% 
  summarise()

############
##fill holes
############
dim(cs18_limits)
head(cs18_limits)
mapview(cs18_limits)
library(mapview)
mapview(cs18_limits)
st_write(cs18_limits,"cs18_limits.geojson")
library(sf)
st_write(cs18_limits,"cs18_limits.geojson")
st_write(cs18_limits,"cs18_limits.gpkg")
getwd()
cs18_limits[121,]
View(cs_18)
cs18_limits[121,]$geom

multi_121 <- cs18_limits[121,]$geom

points_121 <- st_cast(multi_121, "MULTIPOINT")
xy_121 <- st_coordinates(points_121)
xy_121 <- as_tibble(xy_121)
xy_121 <- arrange(xy_121,X,Y)
st_linestring(xy_121)
st_linestring(as.matrix(xy_121))


###
#check single
####
single_127 <- cs18_limits[127,]$geom

