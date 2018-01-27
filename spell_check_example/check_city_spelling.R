install.packages("hunspell")

setwd("~/Box/DataViz Projects/Data Analysis and Visualization/Validate_City_Names/")

#load census place names for california to a character vector
#this will be our spell checking dictionary
library(tigris)
df1 <- places(state="CA")
pldf <- as.data.frame(df1)
setwd("~/Box/DataViz Projects/Data Analysis and Visualization/geocoding/")
ca_place_names_census <- pldf$NAME

#read in some example city names from housing data
library(readr)
df1 <- read_tsv("sample_data/dev_import_Permits_12_8_2017.tsv")

#check the spelling on the housing data jurisdiction column
library(hunspell)

housing_jurisdiction_names <- df1$jurisdictn

spelled_right <- hunspell_check(housing_jurisdiction_names,
                                dict = dictionary(add_words = ca_place_names_census))

city_names_to_review <- unique(df1$jurisdictn[!spelled_right])
print(city_names_to_review)

