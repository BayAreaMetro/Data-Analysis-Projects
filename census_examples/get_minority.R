#install.packages("tidycensus")

library(tidycensus)
library(tidyverse)

counties=c("01","13","41","55","75","81","85","95","97")

setwd("~/Box/DataViz Projects/Data Analysis and Visualization/ACS_examples/")

censuskey = readLines("keys/census1")

census_api_key(censuskey)

#B03002_001E (Total Population)
#B03002_002E (Not Hispanic or Latino)
racevars <- c(Total = "B03002_001",
              White = "B03002_002")

sfdf1 <- get_acs(geography = "tract", variables = racevars,
             state = "CA", county=counties,
             year=2016, keep_geo_vars=TRUE,
             output="wide",
             survey = "acs5", geometry=TRUE)

sfdf1$MinorityEstimate <- sfdf1$TotalE - sfdf1$WhiteE

library(sf)
st_write(sfdf1, "acs_2016_bay_area_minority_population.shp")
st_write(sfdf1, "acs_2016_bay_area_minority_population.geojson")
st_write(sfdf1, "acs_2016_bay_area_minority_population.gpkg")
