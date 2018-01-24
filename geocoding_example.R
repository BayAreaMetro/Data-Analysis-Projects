devtools::install_github("tombuckley/mapsapi")
library(readr)

setwd("~/Box/DataViz Projects/Data Analysis and Visualization/geocoding/")

gmapskey = readLines("keys/gmaps1")
df1 <- read_tsv("sample_data/dev_import_Permits_12_8_2017.tsv")

#take a random sample of 5 address as a character vector
random_addresses <- df1[sample(nrow(df1), 5), ]$address

#bay area bias
n_w= c(-123.695068359375,39.00637903337455)
s_e= c(-120.421142578125,36.35052700542763)
n_w_s <- paste(n_w, sep="", collapse=",")
s_e_s <- paste(s_e, sep="", collapse=",")
bay_area_bbox <- paste(n_w_s,s_e_s,sep="|",collapse="")

#send them to gmaps and get xml
result <- mp_geocode(random_addresses, region="us", key=gmapskey, bounds=bay_area_bbox)

#parse the xml for points
#set all_results to FALSE to just get the top results
df2 <- mp_get_points(result, all_results = TRUE)
