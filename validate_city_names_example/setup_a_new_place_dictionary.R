#here we use census/tiger--but coule be another source
if (!require(tigris)) {
  install.packages('tigris')
}

#setup a places dictionary (e.g. based on tomtom or census)
#based on the instructions
#here: http://www.suares.com/index.php?page_id=25&news_id=233

setwd("~/Documents/Projects/DataVizProjectsGithub/validate_city_names_example")

#load census place names for california to a character vector
#this will be our spell checking dictionary
library(tigris)
df1 <- places(state="CA")
pldf <- as.data.frame(df1)
ca_place_names_census <- pldf$NAME

write(sort(unique(ca_place_names_census)),
      file="placenames_census_ca.dic")
write("",file="placenames_census_ca.aff")
