library(sf)
library(sp)
routes_bus_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="RTD_ROUTES_BUS_MAR_2014_UTM")

stops_bus_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="RTD_ROUTE_STOPS_BUS_MAR_2014_UTM_ADJUSTED_LOCATIONS")

stops_2014 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="RTD_ROUTE_STOPS_ALL_MODES_MAR_2014_UTM")

stops_2013 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="RTD_ROUTE_STOPS_ALL_MODES_UTM_JAN_2013")

df1 <- st_read("/Users/tommtc/Documents/Projects/BAM_github_repos/dv_temp/transit/rtd_backups.gdb", 
               layer="STOPSBUILD_JUNE_2011")