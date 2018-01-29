#read in some example city names from housing data
library(readr)

df1 <- read_tsv("~/Box/DataViz\ Projects/Data\ Analysis\ and\ Visualization/geocoding/sample_data/dev_import_Permits_12_8_2017.tsv")

setwd("~/Documents/Projects/DataVizProjectsGithub/validate_city_names_example")

#check the spelling on the housing data jurisdiction column
library(hunspell)

housing_jurisdiction_names <- df1$jurisdictn

spelled_right <- hunspell_check(housing_jurisdiction_names,
                                dict = dictionary("placenames_census_ca.dic"))

city_names_to_review <- unique(df1$jurisdictn[!spelled_right])
print(city_names_to_review)

spelled_right <- hunspell_check(housing_jurisdiction_names)
