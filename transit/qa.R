library(sf)
library(sp)
library(dplyr)
library(readr)

routes_bus_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="RTD_ROUTES_BUS_MAR_2014_UTM")

rb14_routes <- routes_bus_2014 %>% 
  st_zm() %>%
  group_by(CPT_AGENCYID,SCH_ROUTEDESIGNATOR) %>% 
  summarise()

st_write(rb14_routes,"/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rb14_routes.geojson")

routes18_sf <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/routes.json")

routes_bus_2014_df <- rb14_routes
st_geometry(routes_bus_2014_df) <- NULL

routes_all_2018_df <- routes18_sf
st_geometry(routes_all_2018_df) <- NULL

summary_routes_18 <- routes_all_2018_df %>%
  as_tibble() %>%
  group_by(agency_id) %>%
  summarise(count=n())

summary_routes_14 <- routes_bus_2014_df %>% 
  as_tibble() %>%
  rename(agency_id=CPT_AGENCYID) %>%
  group_by(agency_id) %>%
  summarise(count=n())

summary_14_18 <- left_join(summary_routes_14,
                           summary_routes_18, 
                           by="agency_id",
                           suffix=c(".14",".18"))

write_csv(summary_14_18,"summary_routes_14_18.csv")

# stops_bus_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
#                layer="RTD_ROUTE_STOPS_BUS_MAR_2014_UTM_ADJUSTED_LOCATIONS")
# 
# stops_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
#                layer="RTD_ROUTE_STOPS_ALL_MODES_MAR_2014_UTM")
# 
# stops_2013 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
#                layer="RTD_ROUTE_STOPS_ALL_MODES_UTM_JAN_2013")
# 
# stops_2011 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
#                layer="STOPSBUILD_JUNE_2011")

# layers <- list(routes_bus_2014,
#                stops_bus_2014,
#                stops_2014,
#                stops_2013,
#                stops_2011)
# 
# colnames_l <- lapply(layers,names)
# 
# layers_with_agency <- list(routes_bus_2014,
#                            stops_2014,
#                            stops_2013,
#                            stops_2011)

# summarize_by_agency <- function(df1) {
#   df1 %>% 
#     as_tibble %>%
#     group_by(CPT_AGENCYID) %>%
#     summarise(count=n())
# }
# 
# agency_summaries <- lapply(layers_with_agency,function(x) {summarize_by_agency(x)})

##combine by route to compare
