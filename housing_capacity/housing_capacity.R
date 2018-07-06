library(DBI)
library("aws.s3")
library(RPostgres)
library(dbplyr)
library(dplyr)
library(stringr)
library(htmltab)

#based on year 2010 data use in run 7224 
#the input data are listed in the past (not current) readme, was based off this commit:
#https://github.com/BayAreaMetro/bayarea_urbansim/tree/49228b3e8d7f41137e73d3b0a40d61de8d287577

#####
##S3
library(readr)

parcel_2010 <- read_csv(
  "https://mtcdrive.box.com/shared/static/3z39vzotnmwaj4zyeoicenxxg27401j6.csv")

p10 <- parcel_2010 %>% select(parcel_id,x,y,zoned_du,
                       zoned_du_underbuild,
                       zoned_du_underbuild_nodev,
                       total_residential_units)

p_geog_df <- as.data.frame(parcels_gdb) %>% 
  select (PARCEL_ID,
          COUNTY_ID,
          pda_id,tpp_id,
          tpa_id,jurisdiction,
          manual_county,
          alt_zoning,
          zonetype,
          zoningmodcat,
          X,
          Y)

p10_g <- left_join(p10,
                   p_geog_df,
                   by=c("parcel_id"="PARCEL_ID"))

#A) Total housing capacity within Transit Priority Areas, 
#using our zoning and parcel databases (calc could be du/ac x parcel area) 
#and subtracting this from current housing units (either using ACS or the parcel database), 
#if possible reported by city, county, and rail transit corridor (i.e. all TPAs around BART stations)

#Total housing capacity within Priority Development Areas, 
#using same analysis described above, if possible reported by PDA, City and County.

p10_g <- left_join(p10,
                   p_geog_df,
                   by=c("parcel_id"="PARCEL_ID"))

write_csv(p10_g,
  "parcels_capacity_geography_run7224.csv")

#by city

city_capacity_run7224 <- p10_g %>% 
  group_by(jurisdiction) %>%
  summarise(
    zoned_du=round(sum(zoned_du),-3)/1000,
    zoned_du_underbuild=round(sum(zoned_du_underbuild),-3)/1000,
    zoned_du_underbuild_nodev=round(sum(zoned_du_underbuild_nodev),-3)/1000,
    total_residential_units=round(sum(total_residential_units),-3)/1000
  )

#######
######
###tomtom city names
###need to pull these from the database

con <- dbConnect(odbc::odbc(), "GISDB3")
ap <- tbl(con,in_schema("tomtom_2016","tt_ap")) %>% as_tibble()
rm(con)

ap$customcode <- str_sub(ap$apcode, 3)

ap1 <- ap %>%
  select(customcode,
              name)

city_capacity_run7224 <- left_join(city_capacity_run7224,ap1,by=c("jurisdiction"="customcode"))

write_csv(city_capacity_run7224,
          "city_capacity_run7224.csv")

#by county--will let the user figure out, not too many

county_capacity_run7224 <- p10_g %>% 
  group_by(manual_county) %>%
  summarise(
    zoned_du=round(sum(zoned_du),-3)/1000,
    zoned_du_underbuild=round(sum(zoned_du_underbuild),-3)/1000,
    zoned_du_underbuild_nodev=round(sum(zoned_du_underbuild_nodev),-3)/1000,
    total_residential_units=round(sum(total_residential_units),-3)/1000
  )

write_csv(county_capacity_run7224,
          "county_capacity_run7224.csv")

#by rail transit corridor

tpp_capacity_run7224 <- p10_g %>% 
  group_by(tpp_id) %>%
  summarise(
    zoned_du=round(sum(zoned_du),-3)/100,
    zoned_du_underbuild=round(sum(zoned_du_underbuild),-3)/100,
    zoned_du_underbuild_nodev=round(sum(zoned_du_underbuild_nodev),-3)/100,
    total_residential_units=round(sum(total_residential_units),-3)/100
  )

write_csv(tpp_capacity_run7224,
          "tpp_capacity_run7224.csv")

tpa_capacity_run7224 <- p10_g %>% 
  group_by(tpa_id) %>%
  summarise(
    zoned_du=round(sum(zoned_du),-3)/100,
    zoned_du_underbuild=round(sum(zoned_du_underbuild),-3)/100,
    zoned_du_underbuild_nodev=round(sum(zoned_du_underbuild_nodev),-3)/100,
    total_residential_units=round(sum(total_residential_units),-3)/100
  )

write_csv(tpa_capacity_run7224,
          "tpa_capacity_run7224.csv")

pda_capacity_run7224 <- p10_g %>% 
  group_by(pda_id) %>%
  summarise(
    zoned_du=round(sum(zoned_du),-3)/100,
    zoned_du_underbuild=round(sum(zoned_du_underbuild),-3)/100,
    zoned_du_underbuild_nodev=round(sum(zoned_du_underbuild_nodev),-3)/100,
    total_residential_units=round(sum(total_residential_units),-3)/100
  )

write_csv(pda_capacity_run7224,
          "pda_capacity_run7224.csv")
