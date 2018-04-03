setwd("~/Downloads")

#melt the data
tmc_fwy <- readxl::read_excel("Freeway  TMC List.xlsx")

tmc_fwy_t <- as.tibble(t(tmc_fwy))

tmc_fwy_t$route_id <- rownames(tmc_fwy_t)

tmc_fwy_t_m <- reshape2::melt(tmc_fwy_t, id='route_id')

tmc_fwy_t_m <- dplyr::select(tmc_fwy_t_m,-variable)

tmc_fwy_t_m <- tmc_fwy_t_m[!is.na(tmc_fwy_t_m$value),]

tmc_fwy_t_m <- dplyr::rename(tmc_fwy_t_m,inrix_tmc=value)

#join it to the speed limits
tmc_limits <- readxl::read_excel("nw_sf_speed_limit_all_vars.xlsx")

tmc_limits$inrix_tmc <- stringr::str_sub(tmc_limits$rdstmc, 2)

tmc_fwy_t_m <- dplyr::left_join(tmc_fwy_t_m,tmc_limits,  by = "inrix_tmc")

readr::write_excel_csv(tmc_fwy_t_m, "Freeway_TMC_List_Speed_Limits.csv") 

#review problem tmc from vlookup
problem_o <- "105-04566"
tmc_limits %>% filter(grepl(grepl(problem_o),inrix_tmc))

#put tmc's with speed less than 50 on a map

library(sf)
df_sf <- st_read("/Users/tommtc/Data/nw_sf_speed_limit_all_cars.gpkg")

df_sf$inrix_tmc <- stringr::str_sub(df_sf$rdstmc, 2)

slow_highway_tmcs <- tmc_fwy_t_m[tmc_fwy_t_m$speed<50,]$inrix_tmc

library(mapview)

#look at some slower links on a map
slow_tmc_geoms <- df_sf[df_sf$inrix_tmc %in% slow_highway_tmcs,]

#these are near the GG bridge toll plaza
mapview(slow_tmc_geoms[1,],  map.types=c('Stamen.Toner.Light'))
mapview(slow_tmc_geoms[2,],  map.types=c('Stamen.Toner.Light'))
mapview(slow_tmc_geoms[4,],  map.types=c('Stamen.Toner.Light'))



