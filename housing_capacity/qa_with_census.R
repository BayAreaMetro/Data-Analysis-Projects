library(tidycensus)
library(dplyr)
library(tidyr)
library(readr)

counties=c("01","13","41","55","75","81","85","95","97")

censuskey = readLines("~/Box/DataViz Projects/Data Analysis and Visualization/ACS_examples/keys/census1")

census_api_key("", install=TRUE)

tablename <- "B25001"

acs_vars <- load_variables(2016, "acs5", cache = TRUE)

vars <- dplyr::filter(acs_vars, grepl(tablename,name))

output_table16 <- get_acs(geography = "block group", 
                          variables = "B25001_001E",
                          state = "CA", county=counties,
                          year=2016, 
                          geometry = TRUE)

output_table10 <- get_acs(geography = "block group", 
                        variables = "B25001_001E",
                        state = "CA", county=counties,
                        year=2010)

output_table16$coef_vrtn <- (((output_table16$moe/1.645)/output_table16$estimate)*100)

output_table10$coef_vrtn <- (((output_table10$moe/1.645)/output_table10$estimate)*100)

output_table10 <- output_table10 %>% 
  rename(unit10 = estimate, coef_vrtn10 = coef_vrtn) %>% 
  select(unit10,coef_vrtn10,GEOID)

output_table16 <- output_table16 %>% 
  rename(unit16 = estimate, coef_vrtn16 = coef_vrtn) %>% 
  select(unit16,coef_vrtn16, geometry, GEOID)

housing_units_2010_2016 <- left_join(output_table16,output_table10, by="GEOID")

housing_units_2010_2016 <- st_transform(housing_units_2010_2016,crs=26910)

housing_units_2010_2016 <- housing_units_2010_2016[housing_units_2010_2016$coef_vrtn10<25,]

hsng_cncs_slct <- housing_units_2010_2016 %>% 
  select(unit10,unit16,geoid,geometry)

sample_p10_sf <- p10_g_sf %>% select(total_residential_units,zoned_du,zoned_du_underbuild,zoned_du_underbuild_nodev,geometry)

(hsng_cncs_slct_agg = aggregate(sample_p10_sf, hsng_cncs_slct, sum))

st_geometry(hsng_cncs_slct_agg) <- NULL

hsng_cncs_slct$geoid <- housing_units_2010_2016$GEOID
hsng_cncs_slct_agg$geoid <- housing_units_2010_2016$GEOID

hsng_cncs_slct2 <- left_join(hsng_cncs_slct, hsng_cncs_slct_agg)

st_write(hsng_cncs_slct2,"housing_units_total_census_block_groups.shp", delete_dsn = TRUE)
st_write(hsng_cncs_slct2,"housing_units_total_census_block_groups.gpkg")
