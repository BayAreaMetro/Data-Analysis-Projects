setwd("~/Downloads")

#melt the data
tmc_fwy <- readxl::read_excel("Freeway  TMC List.xlsx")
tmc_fwy_t <- as.data.frame(t(tmc_fwy))

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

                      
