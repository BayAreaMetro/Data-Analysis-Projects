#Written by Kearey Smith
#Housing Permit Data Exploration

if (!require(readxl)) {
  install.packages('readxl')
}

if (!require(dplyr)) {
  install.packages('dplyr')
}

if (!require(plyr)) {
  install.packages('plyr')
}

if (!require(WriteXLS)) {
  install.packages('WriteXLS')
}

library(readxl)
library(dplyr)
library(plyr)
library(WriteXLS)

# Import 2014 & 2015 & 2016 Datasets
rm(Permits)
setwd("~/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding/data/Collection2016_Source_Spreadsheets")

# Import Datasets
print("# Note -- the Alameda import coerces integers from Piedmont that are incorrectly coded as text")
Alameda2016 <- read_excel("Alameda.xlsx")
ContaCosta2016 <- read_excel("ContaCostaCounty_ALL.xlsx")
Marin2016 <- read_excel("MarinCounty_ALL.xlsx")
Napa2016 <- read_excel("NapaCounty_ALL.xlsx")
SanFrancisco2016 <- read_excel("SanFrancisco_ALL.xlsx")
SanMateo2016 <- read_excel("SanMateo_ALL.xlsx")
SantaClara2016 <- read_excel("SantaClara_ALL.xlsx")
Solano2016 <- read_excel("Solano_ALL-2.xlsx")
Sonoma2016 <- read_excel("SonomaCounty_ALL.xlsx")

###Below we check that the order of the columns is all the same from each county
##
## A shorter way to do this is:

tbl_header_order <- names(Alameda2016)

#Join Datasets
Permits2016 <- rbind(Alameda2016[,tbl_header_order],
                     ContaCosta2016[,tbl_header_order],
                     Marin2016[,tbl_header_order],
                     Napa2016[,tbl_header_order],
                     SanFrancisco2016[,tbl_header_order],
                     SanMateo2016[,tbl_header_order],
                     SantaClara2016[,tbl_header_order],
                     Solano2016[,tbl_header_order],
                     Sonoma2016[,tbl_header_order])

#Rescan table to search/fix bad records in fields
#Santa Rosa has bad values for projname, zip, address
#values should be projname = zip | zip = address | address = projname

sr_projname <- subset(Permits2016$projname, Permits2016$jurisdictn == 'Santa Rosa')
sr_zip <- subset(Permits2016$zip, Permits2016$jurisdictn == 'Santa Rosa')
sr_address <- subset(Permits2016$address, Permits2016$jurisdictn == 'Santa Rosa')

Permits2016$projname[Permits2016$jurisdictn == 'Santa Rosa'] <- sr_address
Permits2016$zip[Permits2016$jurisdictn == 'Santa Rosa'] <- sr_projname
Permits2016$address[Permits2016$jurisdictn == 'Santa Rosa'] <- sr_projname

unique(Permits2016$zip)
Permits2016$zip[Permits2016$zip == '1'] <- NA
Permits2016$zip[Permits2016$zip == '2'] <- NA
Permits2016$zip[Permits2016$zip == ' 94954'] <- '94954'

# Fix NA values for num cols.
Permits2016 <- Permits2016 %>%
  mutate(verylow = ifelse(is.na(verylow),0,verylow)) %>%
  mutate(low = ifelse(is.na(low),0,low)) %>%
  mutate(moderate = ifelse(is.na(moderate),0,moderate)) %>%
  mutate(abovemod = ifelse(is.na(abovemod),0,abovemod)) %>%
  mutate(totalunit = ifelse(is.na(totalunit),0,totalunit)) %>%
  mutate(infill = ifelse(is.na(infill),0,infill)) %>%
  mutate(affrdunit = ifelse(is.na(affrdunit),0,affrdunit)) %>%
  mutate(deedaffrd = ifelse(is.na(deedaffrd),0,deedaffrd)) %>%
  mutate(asstaffrd = ifelse(is.na(asstaffrd),0,asstaffrd)) %>%
  mutate(opnaffrd = ifelse(is.na(opnaffrd),0,opnaffrd))
  
# Drop unneccessary dfs
rm(Alameda2016, ContaCosta2016, Marin2016, Napa2016, SanFrancisco2016, SanMateo2016, SantaClara2016, Solano2016, Sonoma2016)

Permits2016$jurisdictn[Permits2016$jurisdictn == 'NAPA COUNTY'] <- 'Napa County'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Alameda County'] <- 'Alameda Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Contra Costa County'] <- 'Contra Costa Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Marin County'] <- 'Marin Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Napa County'] <- 'Napa Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'San Mateo County'] <- 'San Mateo Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Santa Clara County'] <- 'Santa Clara Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Solano County'] <- 'Solano Unincorporated'
Permits2016$jurisdictn[Permits2016$jurisdictn == 'Sonoma County'] <- 'Sonoma Unincorporated'

setwd("~/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding/data/")
write.csv(Permits2016, "Permits2016.csv", na="NULL")
