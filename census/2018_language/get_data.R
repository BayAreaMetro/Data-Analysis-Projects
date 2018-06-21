install.packages("tidycensus")
library(tidycensus)
library(dplyr)
library(tidyr)
library(readr)

counties=c("01","13","41","55","75","81","85","95","97")

censuskey = readLines("~/Box/DataViz Projects/Data Analysis and Visualization/ACS_examples/keys/census1")

census_api_key(censuskey)

languages_table <- "B16001"

acs_vars <- load_variables(2016, "acs5", cache = FALSE)

language_variables <- dplyr::filter(acs_vars, grepl(languages_table,name))

shortnames <- c('Spanish', 'Chinese', 'Vietnamese', 'Tagalog', 'Korean')
census_vars <- c('B16001_005',
                 'B16001_077',
                 'B16001_089',
                 'B16001_101',
                 'B16001_083')

language_table <- get_acs(geography = "tract", 
                             variables = census_vars,
                             state = "CA", county=counties,
                             year=2015,
                             summary_var = "B16001_001")

better_names_df <- tibble(variable = census_vars, language=shortnames)

language_table_named <- left_join(language_table,better_names_df) %>%
  select(GEOID,variable,estimate,language)

language_table_wide <- language_table_named %>% spread(language, estimate)

write_csv(language_table_wide,"~/Documents/Projects/BAM_github_repos/dv_temp/census/2018_language/language_table_acs_2015.csv")
