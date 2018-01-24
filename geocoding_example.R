devtools::install_github("michaeldorman/mapsapi")
library(readr)

setwd("~/Box/DataViz Projects/Data Analysis and Visualization/geocoding/")

gmapskey = readLines("keys/gmaps1")
df1 <- read_tsv("sample_data/dev_import_Permits_12_8_2017.tsv")

#take a random sample of 5 address as a chracter vector
random_addresses <- df1[sample(nrow(df1), 5), ]$address

#send them to gmaps and get xml
result <- mp_geocode(random_addresses, region=us, key=gmapskey)

#parse the xml for points
#set all_results to FALSE to just get the top results
df2 <- mp_get_points(result, all_results = TRUE)
