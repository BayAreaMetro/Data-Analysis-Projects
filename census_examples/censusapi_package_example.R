#########################################################################################################
# This R Script explores various Census Related Datasets
# Author: KS
# It uses the censusapi library which is documented here:[CensusAPI](https://hrecht.github.io/censusapi/index.html)

#########################################################################################################
library(censusapi)
library(dplyr)
library(tidyr)
#########################################################################################################
#This key is private and should not be shared via GitHub.  It is here for internal use only.  This portion of the code should be removed when sharing to Github.
#########################################################################################################
Sys.getenv("CENSUS_TOKEN")
# Add key to .Renviron
Sys.setenv(CENSUS_KEY='5fbaa5725148859f644e88cd2c738b394616a684')
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")
#########################################################################################################
#Find the API that you would like to use.
apis <- listCensusApis()
#########################################################################################################
acs5_geog <- listCensusMetadata(name="acs/acs5", vintage=2016, type = "g")
acs5_vars <- listCensusMetadata(name="acs/acs5", vintage=2016, type = "v")
acs5_vars_flows <- listCensusMetadata(name="acs/flows", vintage=2015, type = "v")
#########################################################################################################
# Get Selected Data Sets
#########################################################################################################
# Concept: HISPANIC OR LATINO ORIGIN BY RACE
#########################################################################################################
acs5_vars %>%
  filter(group %in% c('C02003')) %>%
  select(name, label, group) -> HispanicVars

HispanicData <- getCensus(name="acs/acs5", vintage=2016,
                          vars=HispanicVars[,1], 
                          region="tract:*", 
                          regionin="state:06+county:001,013,041,055,075,081,085,095,097")

names(HispanicData) <- c('State','County','Tract') #Need to populate the other 21 fields
#########################################################################################################
# Concept: DETAILED RACE
#########################################################################################################
acs5_vars %>%
  filter(group %in% c('B03002')) %>%
  select(name, label, group) -> DetailedRaceVars

DetailedRaceData <- getCensus(name="acs/acs5", vintage=2016,
                           vars=DetailedRaceVars[,1], 
                           region="tract:*", 
                           regionin="state:06+county:001,013,041,055,075,081,085,095,097")

names(DetailedRaceData) <- c('State','County','Tract','AIAN','Asian','NHOPI','White','Black','Total_Pop','Tot_Pop_One_Race','Other')
#########################################################################################################
