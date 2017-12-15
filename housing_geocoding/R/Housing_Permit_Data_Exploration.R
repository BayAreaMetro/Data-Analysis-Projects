#Written by Kearey Smith
#Housing Permit Data Exploration

library(readxl)
library(dplyr)
library(plyr)
library(WriteXLS)

# Import 2014 & 2015 & 2016 Datasets
rm(Permits)
Permit <- read_tsv("~/Documents/ArcGIS/Projects/Housing/permit.tsv")

setwd("~/Box/DataViz Projects/Data Services/Housing/Permits2016")
# Import Datasets
Alameda2016 <- read_excel("Alameda.xlsx")
ContaCosta2016 <- read_excel("ContaCostaCounty_ALL.xlsx")
Marin2016 <- read_excel("MarinCounty_ALL.xlsx")
Napa2016 <- read_excel("NapaCounty_ALL.xlsx")
SanFrancisco2016 <- read_excel("SanFrancisco_ALL.xlsx")
SanMateo2016 <- read_excel("SanMateo_ALL.xlsx")
SantaClara2016 <- read_excel("SantaClara_ALL.xlsx")
Solano2016 <- read_excel("Solano_ALL-2.xlsx")
Sonoma2016 <- read_excel("SonomaCounty_ALL.xlsx")

## Visual Check the correct order for names
names(Alameda2016)
# names(ContaCosta2016)
# names(Marin2016)
# names(Napa2016)
# names(SanMateo2016)
# names(SantaClara2016)
# names(Solano2016)
# names(Sonoma2016)
#Fix any bad field orders
# Reorder By Column Number Example
# data[c(1,3,2)]
# Correct Field Order
# [1] "joinid"     "permyear"   "permdate"   "county"     "jurisdictn" "apn"        [7]"address"    [8]"zip"        [9]"projname"   "hcategory"  "verylow"    "low"        "moderate"   "abovemod"   "totalunit"  "infill"    
# [17] "affrdunit"  "deedaffrd"  "asstaffrd"  "opnaffrd"   "tenure"     "rpa"        "rhna"       "rhnacyc"    "pda"        "pdaid"      "tpa"        "hoa"        "occertiss"  "occertyr"   "occertdt"   "mapped"    
# [33] "notes"
#Bad Field order
# [1] "joinid"     "permyear"   "permdate"   "county"     "jurisdictn" "apn"        [8]"zip"[7]        [9]"projname"[8]   [7]"address"[9]    "hcategory"  "verylow"    "low"        "moderate"   "abovemod"   "totalunit"  "infill"    
# [17] "affrdunit"  "deedaffrd"  "asstaffrd"  "opnaffrd"   "tenure"     "rpa"        "rhna"       "rhnacyc"    "pda"        "pdaid"      "tpa"        "hoa"        "occertiss"  "occertyr"   "occertdt"   "mapped"    
# [33] "notes"     
# FIX 
SanFrancisco2016 <- SanFrancisco2016[c(1,2,3,4,5,6,9,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33)]
SantaClara2016 <- SantaClara2016[c(1,2,3,4,5,6,9,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33)]
Solano2016 <- Solano2016[c(1,2,3,4,5,6,9,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33)]
Sonoma2016 <- Sonoma2016[c(1,2,3,4,5,6,9,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33)]
## Visual Check the correct order for names
names(Alameda2016)
names(ContaCosta2016)
names(Marin2016)
names(Napa2016)
names(SanMateo2016)
names(SantaClara2016)
names(Solano2016)
names(Sonoma2016)

#rm(Permits)
#Join Datasets
Permits2016 <- rbind(Alameda2016,ContaCosta2016,Marin2016,Napa2016,SanFrancisco2016,SanMateo2016,SantaClara2016,Solano2016,Sonoma2016)
names(Permits2016)

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

names(Permit)
names(Permits2016)
Permits_DB <- rbind(Permit, Permits2016)
rm(Permits2016)

# Scan Table to fix bad records

#City Names (There are only 107 unique values. We are missing 2 Jurisdictions)
Jurisdiction <- distinct(Permits_DB, jurisdictn, county)
# Rename jurisdictn values
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'NAPA COUNTY'] <- 'Napa County'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Alameda County'] <- 'Alameda Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Contra Costa County'] <- 'Contra Costa Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Marin County'] <- 'Marin Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Napa County'] <- 'Napa Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'San Mateo County'] <- 'San Mateo Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Santa Clara County'] <- 'Santa Clara Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Solano County'] <- 'Solano Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Sonoma County'] <- 'Sonoma Unincorporated'






# Export df to csv
setwd("~/Documents/ArcGIS/Projects/Housing")

write.csv(Permits_DB, "PermitsDB.csv", na="NULL")


# Summarize Data Affordable Unit Data
# Total Very Low, Low and Moderate Units by (1) County and Jurisdiction, and (2) By County. 
# Sum categories and title Affordable Units.

groupColumns <- c("county","permyear","jurisdictn")
dataColumns <- c("verylow", "low", "moderate")
AffordableHousing <- ddply(Permits_DB, groupColumns, function(x) colSums(x[dataColumns]))
AffordableHousing <- cbind(AffordableHousing, Total = rowSums(AffordableHousing[4:6]))
WriteXLS(AffordableHousing, ExcelFileName = "AffordableHousing.xls")

# Rank Jurisdictions by Total Affordable (Sum of Very Low, Low, Moderate Units)
# See Tableau for Rankings


# Total Units by Geographic Coincidence with PDAs and TPAs. THis is only for 2015
# Their should be 4 conditions met. (1) In PDA Only (2) In TPA Only (3) In PDA & TPA (4) Not In PDA or TPA
AffordableHousing2015 <- subset(Permits_DB, permyear == 2015, select = c("county", "jurisdictn", "pda", "tpa", "verylow", "low", "moderate"))

groupPolicyColumns <- c("county", "jurisdictn","tpa","pda")
dataPolicyColumns <- c("verylow", "low", "moderate")
AHInPolicyAreas2015 <- ddply(AffordableHousing2015, groupPolicyColumns, function(x) colSums(x[dataPolicyColumns]))
AHInPolicyAreas2015 <- cbind(AHInPolicyAreas2015, Total = rowSums(AHInPolicyAreas2015[5:7]))
WriteXLS(AHInPolicyAreas2015, ExcelFileName = "AHInPolicyAreas2015.xls")


# Bind all years to single Table and publish to Sql Server Database ()
# WriteXLS(Permits_DB, ExcelFileName = "Permits_DB.xls")

# Remaining fields to be corrected -- Data Cleansing Tasks
## Check Rules to ensure that fields values are not invalid
unique(Permits_DB$hcategory) ## Values that do not match 5+, 2-4, SF, MH, and SU
unique(Permits_DB$jurisdictn) ## Done
unique(Permits_DB$permyear) ## 2017,2019, 2020
unique(Permits_DB$tenure) ## O and R are only allowed values
unique(Permits_DB$pdaid) ## PDA Vintage Unknown
unique(Permits_DB$hoa)
unique(Permits_DB$rhna) 
# We do not have a field for collection year. Is that important to collect?


# Grab Missing values from Permit_Updates in the housing database

# Build Report with Totals by Year.  Include Charts (Use Taleau to prepare Charts)