setwd("~/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding/data")
Permits2015 <- read.csv("Residential_Building_Permits_attributes.csv", na="NULL")
Permits2016 <- read.csv("Permits2016.csv", na="NULL")

names(Permits2015)
names(Permits2016)

Permits_DB <- rbind(Permits2015[,-1], Permits2016[,-1])
names(Permits_DB)

Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'NAPA COUNTY'] <- 'Napa County'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Alameda County'] <- 'Alameda Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Contra Costa County'] <- 'Contra Costa Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Marin County'] <- 'Marin Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Napa County'] <- 'Napa Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'San Mateo County'] <- 'San Mateo Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Santa Clara County'] <- 'Santa Clara Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Solano County'] <- 'Solano Unincorporated'
Permits_DB$jurisdictn[Permits_DB$jurisdictn == 'Sonoma County'] <- 'Sonoma Unincorporated'

# Scan Table to fix bad records

#City Names (There are only 107 unique values. We are missing 2 Jurisdictions)
Jurisdiction <- distinct(Permits_DB, jurisdictn, county)
# Rename jurisdictn values--this doesn't seem to rename anything--can probably remove

# Export df to csv
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

# Notes: 
# We do not have a field for collection year. Is that important to collect?
# Grab Missing values from Permit_Updates in the housing database
# Build Report with Totals by Year.  Include Charts (Use Tableau to prepare Charts)