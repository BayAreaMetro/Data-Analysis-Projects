library(DBI)
library(RPostgreSQL)
library(sf)
library(dplyr)
library(readxl)
library(jsonlite)

congested_segments_file <- "data/WeekdayCongestedSegmentsList_2017_v2.xlsx" 
database_credentials_file <- "~/credentials/tbuckley_gisdb3.json"

#set the working directory to be that of the script
#assumes user is running r studio
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

cs_18 <- readxl::read_excel(congested_segments_file)

#connect to the db
db3_cred <- jsonlite::read_json(database_credentials_file)

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

cs17_sf <- inner_join(df3,cs_18,by=c("tmcid"="TMC ID"))

cs17_limits <- cs17_sf %>% 
  group_by(LIMITS,startTime,endTime,
           `Route #`,DIR,`Segment Delay  (Veh-Hrs)`,Rank,`length (Miles)`) %>% 
  summarise()

cs17_limits$start_hour <- hour(lubridate::ymd_hms(cs17_limits$startTime))
cs17_limits$start_minute <- minute(lubridate::ymd_hms(cs17_limits$startTime))

cs17_limits$end_hour <- hour(lubridate::ymd_hms(cs17_limits$endTime))
cs17_limits$end_minute <- minute(lubridate::ymd_hms(cs17_limits$endTime))

m1 <- mapview(cs17_limits, zcol="Rank", legend=TRUE)
mapshot(m1, url = paste0(getwd(), "/congested_segments_map17.html"))
st_write(cs17_limits,"cs17_limits.geojson")