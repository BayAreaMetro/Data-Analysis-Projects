library(DBI)
library(sf)
library(RSQLite)

#you can use ogr2ogr to clean csv and load to your favorite local db
#e.g. : ogr2ogr -f SQLite fastrak.sqlite example_fastrak_file.csv
ftdb <- dbConnect(RSQLite::SQLite(), "fastrak.sqlite")

tbl1 <- tbl(ftdb,'example_fastrak_tablename')

#
zip_four_df <- tbl1 %>%
  group_by(zipcode,`zip+4`) %>%
  select(zipcode,`zip+4`) %>%
  summarise(transponder_count = n()) %>%
  as_tibble()

zip_df <- tbl1 %>%
  group_by(zipcode) %>%
  summarise(transponder_count = n())

###
#State of California ZIP
###

#download here:
#http://gis.mtc.ca.gov/home/tomtom.html
tt_db <- "/Users/tommtc/Data/Geocode_state.gdb"
zipcode_sf <- st_read(tt_db,
                      layer = "mn_pd")

ca_zips <- unique(zipcode_sf$POSTCODE)

zip_four_ca_df <- zip_four_df[zip_four_df$zipcode %in%
                                 ca_zips,]

zip_ca_df <- zip_df[zip_df$zipcode %in%
                       ca_zips,]

transponder_count_sf <- left_join(zipcode_sf,
                                  zip_df,
                                  by=c("POSTCODE"="zipcode"))

write_csv(zip_four_ca_df,"transponder_count_by_zip4_ca.csv")
st_write(transponder_count_sf, "transponder_count_by_zip_ca.shp")
st_write(transponder_count_sf, "transponder_count_by_zip_ca.csv")

###
#Bay Area ZIP
###

#download here:
#http://gis.mtc.ca.gov/home/tomtom.html
tt_db <- "/Users/tommtc/Data/Geocode_region.gdb"
zipcode_sf <- st_read(tt_db,
                      layer = "mn_pd_BayArea")

bay_zips <- unique(zipcode_sf$POSTCODE)

zip_four_bay_df <- zip_four_df[zip_four_df$zipcode %in%
                                 bay_zips,]

zip_ca_df <- zip_df[zip_df$zipcode %in%
                      bay_zips,]

transponder_count_sf <- left_join(zipcode_sf,
                                  zip_df,
                                  by=c("POSTCODE"="zipcode"))

write_csv(zip_four_ca_df,"transponder_count_by_zip4_bay.csv")
st_write(transponder_count_sf, "transponder_count_by_zip_bay.shp")
st_write(transponder_count_sf, "transponder_count_by_zip_bay.csv")

transponder_count_simple <- st_simplify(transponder_count_sf, preserveTopology=FALSE, dTolerance=1000)

transponder_count_sketch <- transponder_count_simple[transponder_count_simple$transponder_count>500,]

m1 <- qtm(transponder_count_sketch,lines.lwd = 0,fill="transponder_count")

tmap_save(m1, filename = "transponder_count.png")

