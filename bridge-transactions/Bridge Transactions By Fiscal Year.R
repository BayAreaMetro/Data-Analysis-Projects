#Build FasTrak Transactions Database
#put the final input data in a final folder
#put everything else in an archived folder


library(dplyr)
library(sqldf)
library(tidyr)
library(data.table)
library(lubridate)
library(WriteXLS)
library(lettercase)
library(stringi)
library(reshape2)
library(readr)
library(readxl)
library(anytime)
library(janitor)

setwd("~/Box/DataViz Projects/Data Analysis and Visualization/Fastrak Users")

###########################################################################################
#FUNCTIONS
###########################################################################################
#from https://stackoverflow.com/questions/12945687/read-all-worksheets-in-an-excel-workbook-into-an-r-list-with-data-frames#12945838
read_excel_allsheets <- function(filename, column_types) {
  sheets <- readxl::excel_sheets(filename)
  x <-    lapply(sheets, 
                 function(X) readxl::read_excel(filename, 
                                                sheet = X, 
                                                col_types = column_types))
  names(x) <- sheets
  return(x)
}


multidate <- function(data, formats){
  a<-list()
  for(i in 1:length(formats)){
    a[[i]]<- as.Date(data,format=formats[i])
    a[[1]][!is.na(a[[i]])]<-a[[i]][!is.na(a[[i]])]
  }
  a[[1]]
}

# Simple Negate Function
'%ni%' <- Negate('%in%')

###########################################################################################
#DATA
###########################################################################################
# County Boundaries
###########################################################################################
# Import County / Postcode table for County to Zip Matches
# ADD: out of region totals
# and classify people that are coming from out of region
ba_county_geoid <- c('6041','6055','6095','6097','6081','6001','6085','6013','6075')
us_zips <- read_csv("processed/zcta_county_rel_10.csv", col_names = TRUE)
us_zips <- us_zips[,c('STATE','GEOID','ZCTA5','COUNTY','ZPOPPCT')]

#take row with top zpop value 
us_zips <- us_zips %>% group_by(ZCTA5) %>% top_n(1, ZPOPPCT)

us_zips %>% 
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "001", "Alameda", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "013", "Contra Costa", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "041", "Marin", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "055", "Napa", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "075", "San Francisco", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "081", "San Mateo", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "085", "Santa Clara", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "095", "Solano", COUNTY)) %>%
  mutate(COUNTY = ifelse(STATE == 6 && COUNTY == "097", "Sonoma", COUNTY)) %>%
  mutate(COUNTY = ifelse(GEOID %ni% ba_county_geoid, "Out of Region", COUNTY)) -> us_zips

us_zips <- us_zips[,3:4]
names(us_zips) <- c("POSTCODE", "County")
###########################################################################################
# Read in Data from Spreadsheets for FY 16/17
###########################################################################################

column_types = c("text", "numeric", "date", "text", "numeric")
filename <- "unprocessed/Sylvia/FY16-17 Query/Data_Jul-2016_To_Jun-2017.xlsx"
mysheets <- read_excel_allsheets(filename,column_types)
#from https://stackoverflow.com/questions/2851327/convert-a-list-of-data-frames-into-one-data-frame#2851434
library(plyr)
BridgeTransactionsFY16_17 <- ldply(mysheets, data.frame)
rm(mysheets)

# Rename Columns for consistency across all years
names(BridgeTransactionsFY16_17) <- c("month_sheet","Plaza Name","Bridge","Date","POSTCODE", "Transactions")

BridgeTransactionsFY16_17 <- BridgeTransactionsFY16_17[,-2]
# Reorder Columns to common structure for consistency across all years
# POSTCODE, Bridge, Date, Transactions
BridgeTransactionsFY16_17 <- BridgeTransactionsFY16_17[c('POSTCODE', 'Bridge', 'Date', 'Transactions')]

BridgeTransactionsFY16_17$FiscalYear <- "FY16/17"

#BridgeTransactionsFY16_17[is.na(BridgeTransactionsFY16_17$Date),]
#End of FY 16/17
###########################################################################################
# Read in Data from Spreadsheets for FY 15/16
###########################################################################################
column_types = c("date", "text", "numeric", "text", "numeric")
filename <- "unprocessed/Sylvia/FY15-16 Query/Query_2016_Jan-Jun.xlsx"
mysheets2 <- read_excel_allsheets(filename,column_types)
#from https://stackoverflow.com/questions/2851327/convert-a-list-of-data-frames-into-one-data-frame#2851434
library(plyr)
BridgeTransactionsFY15_16_1 <- ldply(mysheets2, data.frame)
rm(mysheets2)

#thought: we should consider renaming from existing names explicitly, 
#and maybe do it on the excel sheet read to be more robust against random headers
names(BridgeTransactionsFY15_16_1) <- c("month_sheet","Date","Plaza Agency","Bridge","POSTCODE", "Transactions")
BridgeTransactionsFY15_16_1 <- BridgeTransactionsFY15_16_1[-3]

column_types <- c("date", "text", "numeric", "text", "numeric")
mysheets3 <- read_excel_allsheets("unprocessed/Sylvia/FY15-16 Query/Query 2015-Jul-Dec.xlsx", column_types)
library(plyr)
BridgeTransactionsFY15_16 <- ldply(mysheets3, data.frame)
#Column Fixes
setnames(BridgeTransactionsFY15_16, old=c(".id","Txn.Date","Plaza.Agency","Plaza.Id","Zip.Code","Count"), 
         new=c("month_sheet","Date","Plaza Agency","Bridge","POSTCODE","Transactions"))

BridgeTransactionsFY15_16 <- BridgeTransactionsFY15_16[-3]

BridgeTransactionsFY15_16 <- rbind(BridgeTransactionsFY15_16,
                                   BridgeTransactionsFY15_16_1)

BridgeTransactionsFY15_16$FiscalYear <- "FY15/16"
#End of FY15/16
###########################################################################################
###########################################################################################
# Read in Data from Spreadsheets for FY 14/15
###########################################################################################

# This table requires melt function due to its format
x2015_Jan_Jun <- read_csv("unprocessed/Sylvia/FY14-15 Query/Zip Code Query Jan2015-Jun2015.csv",cols(.default = col_character()), col_names = TRUE)
x2015_Jan_Jun <- x2015_Jan_Jun[-1]
x2015_Jan_Jun <- x2015_Jan_Jun[-184]
# Pivot Date Values using Melt
x2015_Jan_Jun <- melt(x2015_Jan_Jun,id=c("PLAZA", "ZIP_CODE"), na.rm=TRUE)
names(x2015_Jan_Jun) <- c("Bridge", "POSTCODE","Date","Transactions")
# Reorder Columns to common structure for consistency across all years
# POSTCODE, Bridge, Date, Transactions
x2015_Jan_Jun <- x2015_Jan_Jun[c(2,1,3,4)]
# Fix Column Formats
x2015_Jan_Jun$Date <- as.character(x2015_Jan_Jun$Date)
x2015_Jan_Jun$Transactions <- as.numeric(x2015_Jan_Jun$Transactions)

# This table requires melt function due to its format
x2014_Jul_Dec <- read_csv("unprocessed/Sylvia/FY14-15 Query/July thru Dec 2014_missing 2 bridges.csv",cols(.default = col_character()), col_names = TRUE)
x2014_Jul_Dec <- x2014_Jul_Dec[-1]
x2014_Jul_Dec <- x2014_Jul_Dec[-187]

# Pivot Date Values using Melt
x2014_Jul_Dec <- melt(x2014_Jul_Dec,id=c("PLAZA", "ZIP_CODE"), na.rm=TRUE)
names(x2014_Jul_Dec) <- c("Bridge", "POSTCODE","Date","Transactions")
# Reorder Columns to common structure for consistency across all years
# POSTCODE, Bridge, Date, Transactions
x2014_Jul_Dec <- x2014_Jul_Dec[c(2,1,3,4)]
# Fix Column Formats
# x2014_Jul_Dec$Date <- as.character(x2014_Jul_Dec$Date)
# x2014_Jul_Dec$Transactions <- as.numeric(x2014_Jul_Dec$Transactions)

BridgeTransactionsFY14_15 <- rbind(x2014_Jul_Dec,x2015_Jan_Jun)

BridgeTransactionsFY14_15$Transactions <- as.numeric(BridgeTransactionsFY14_15$Transactions)
BridgeTransactionsFY14_15$Date <- as.Date(BridgeTransactionsFY14_15$Date, "%m/%d/%y")
BridgeTransactionsFY14_15$FiscalYear<- "FY14/15"

rm(x2014_Jul_Dec,x2015_Jan_Jun)

# End of FY14/15
###########################################################################################
# Read in Data from Spreadsheets for FY 13/14
###########################################################################################
# This table requires melt function due to its format
x2014_Jan_Jun <- read_excel("unprocessed/Sylvia/FY13-14 Query/ZIPCODE_QUERY_Jan - June 2014.xlsx")

# Pivot Date Values using Melt
x2014_Jan_Jun <- melt(x2014_Jan_Jun,id=c("PLAZA_ID", "ZIP_CODE"), na.rm=TRUE)
names(x2014_Jan_Jun) <- c("Bridge", "POSTCODE","Date","Transactions")
# Reorder Columns to common structure for consistency across all years
# POSTCODE, Bridge, Date, Transactions
x2014_Jan_Jun <- x2014_Jan_Jun[c(2,1,3,4)]
# Fix Column Formats
x2014_Jan_Jun$Date <- as.character(x2014_Jan_Jun$Date)
x2014_Jan_Jun$Transactions <- as.numeric(x2014_Jan_Jun$Transactions)

BridgeTransactionsFY13_14 <- x2014_Jan_Jun

BridgeTransactionsFY13_14$Transactions <- as.numeric(BridgeTransactionsFY13_14$Transactions)

BridgeTransactionsFY13_14$Date <- as.Date(BridgeTransactionsFY13_14$Date, "%m/%d/%Y")
BridgeTransactionsFY13_14$FiscalYear<- "FY13/14"

rm(x2014_Jan_Jun)

# End of FY13/14
###########################################################################################
# Read in Data from Spreadsheets for FY 10/13
###########################################################################################
BridgeTransactionsFY10_13 <- read_csv("unprocessed/County/FasTrakThroughTime.csv", 
                                      col_types = cols(Date = col_datetime(format = "%Y-%m-%d %H:%M:%S"), 
                                                       Zipcode = col_character()))

names(BridgeTransactionsFY10_13) <- c("POSTCODE","Date","Bridge","Transactions", "County")
# Check Column Types to ensure proper schema across all data frames
BridgeTransactionsFY10_13$Bridge <- as.character(BridgeTransactionsFY10_13$Bridge)

# Fix County Name Text Case
BridgeTransactionsFY10_13$County <- stri_trans_general(BridgeTransactionsFY10_13$County, id = "Title")

#Filter List down to Bay Area County Transactions
#BridgeTransactionsFY10_13 <- sqldf("select * from BridgeTransactionsFY10_13 where County in ('Alameda','Contra Costa','Marin','Napa','San Francisco','San Mateo','Santa Clara','Solano','Sonoma')")
#This may only have california counties.  Need to verify.

BridgeTransactionsFY10_13 %>% 
  mutate(County = ifelse(County %ni% c('Alameda', 'Contra Costa','Marin','Napa','San Francisco','San Mateo','Santa Clara','Solano','Sonoma'), "Out of Region", County)) -> BridgeTransactionsFY10_13

# Fix Bridge Names so that they are unique and have the same name for each Bridge
BridgeTransactionsFY10_13$Bridge <- gsub('CALT/', '', BridgeTransactionsFY10_13$Bridge)

BridgeTransactionsFY10_13 %>% 
  mutate(Bridge = ifelse(Bridge == "Bay Bridge", "San Francisco-Oakland Bay Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "San Mateo", "San Mateo-Hayward Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "Richmond San Rafael Bridge", "Richmond-San Rafael Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "GGBD/Golden Gate Bridge", "Golden Gate Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "San Francisco Oakland Bay Bridge", "San Francisco-Oakland Bay Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "Benicia", "Benicia-Martinez Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "Richmond", "Richmond-San Rafael Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "San Mateo Hayward Bridge", "San Mateo-Hayward Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "GGB/Golden Gate Bridge", "Golden Gate Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "HYBD/Bay Bridge HOV", "San Francisco-Oakland Bay Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "HYBD/Carquinez HOV", "Carquinez Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "HYBD/Dumbarton HOV", "Dumbarton Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "HYBD/San Mateo HOV", "San Mateo-Hayward Bridge", Bridge)) %>%
  mutate(Bridge = ifelse(Bridge == "Benicia Martinez Bridge", "Benicia-Martinez Bridge", Bridge))-> BridgeTransactionsFY10_13

BridgeTransactionsFY10_13 <- sqldf("select * From BridgeTransactionsFY10_13 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")

# Reorder fields to match final output schema
BridgeTransactionsFY10_13 <- BridgeTransactionsFY10_13[c(5,1,3,2,4)]

#Mutate to add FY for 10 thru 13 based upon Date field  This dataset contains multiple FYs

BridgeTransactionsFY10_13$FiscalYear<- "FY10/13"

BridgeTransactionsFY10_13 %>%
  mutate(FiscalYear = ifelse(between(Date, as.Date("2009-12-31"), as.Date("2010-06-30")),"FY09/10", FiscalYear)) %>%
  mutate(FiscalYear = ifelse(between(Date, as.Date("2010-06-30"), as.Date("2011-07-01")),"FY10/11", FiscalYear)) %>%
  mutate(FiscalYear = ifelse(between(Date, as.Date("2011-06-30"), as.Date("2012-07-01")),"FY11/12", FiscalYear)) %>%
  mutate(FiscalYear = ifelse(between(Date, as.Date("2012-06-30"), as.Date("2013-07-01")),"FY12/13", FiscalYear)) %>%
  mutate(FiscalYear = ifelse(between(Date, as.Date("2013-06-30"), as.Date("2014-07-01")),"FY13/14", FiscalYear)) -> BridgeTransactionsFY10_13

# unique(BridgeTransactionsFY10_13$FiscalYear)

# End of FY10/13
###########################################################################################
# Merge with County Zip Correspondence
###########################################################################################
BridgeTransactionsFY13_14 <- merge(BridgeTransactionsFY13_14, us_zips, by="POSTCODE")
BridgeTransactionsFY14_15 <- merge(BridgeTransactionsFY14_15, us_zips, by="POSTCODE")
BridgeTransactionsFY15_16 <- merge(BridgeTransactionsFY15_16, us_zips, by="POSTCODE")
BridgeTransactionsFY16_17 <- merge(BridgeTransactionsFY16_17, us_zips, by="POSTCODE")
# End of Merge
###########################################################################################
#Check Field Order for All Inputs
###########################################################################################
#Reorder Fields to match common output & Bind all Data frames
BridgeTransactionsFY10_13 <- BridgeTransactionsFY10_13[c("POSTCODE","Bridge","Date","Transactions", "FiscalYear", "County")]
BridgeTransactionsFY14_15 <- BridgeTransactionsFY14_15[c("POSTCODE","Bridge","Date","Transactions", "FiscalYear", "County")]
BridgeTransactionsFY15_16 <- BridgeTransactionsFY15_16[c("POSTCODE","Bridge","Date","Transactions", "FiscalYear", "County")]
BridgeTransactionsFY16_17 <- BridgeTransactionsFY16_17[c("POSTCODE","Bridge","Date","Transactions", "FiscalYear", "County")]

BridgeTransactions <- rbind(BridgeTransactionsFY10_13,BridgeTransactionsFY13_14,BridgeTransactionsFY14_15,BridgeTransactionsFY15_16,BridgeTransactionsFY16_17)

#Check for bad dates
length(which(is.na(BridgeTransactions$Date)))
length(which(is.na(BridgeTransactionsFY10_13$Date)))
length(which(is.na(BridgeTransactionsFY13_14$Date)))
length(which(is.na(BridgeTransactionsFY14_15$Date)))
length(which(is.na(BridgeTransactionsFY15_16$Date)))
length(which(is.na(BridgeTransactionsFY16_17$Date)))

# End of Bind Operation
###########################################################################################
# Reassign Bridge attribute from Code to Name
###########################################################################################
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "02" | BridgeTransactions$Bridge == "2"] <- "Antioch Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "03" | BridgeTransactions$Bridge == "3"] <- "Richmond-San Rafael Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "04" | BridgeTransactions$Bridge == "4"] <- "San Francisco-Oakland Bay Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "05" | BridgeTransactions$Bridge == "5"] <- "San Mateo-Hayward Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "06" | BridgeTransactions$Bridge == "6"] <- "Dumbarton Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "07" | BridgeTransactions$Bridge == "7"] <- "Carquinez Bridge"
BridgeTransactions$Bridge[BridgeTransactions$Bridge == "08" | BridgeTransactions$Bridge == "8"] <- "Benicia-Martinez Bridge"

BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "02" | BridgeTransactionsFY13_14$Bridge == "2"] <- "Antioch Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "03" | BridgeTransactionsFY13_14$Bridge == "3"] <- "Richmond-San Rafael Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "04" | BridgeTransactionsFY13_14$Bridge == "4"] <- "San Francisco-Oakland Bay Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "05" | BridgeTransactionsFY13_14$Bridge == "5"] <- "San Mateo-Hayward Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "06" | BridgeTransactionsFY13_14$Bridge == "6"] <- "Dumbarton Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "07" | BridgeTransactionsFY13_14$Bridge == "7"] <- "Carquinez Bridge"
BridgeTransactionsFY13_14$Bridge[BridgeTransactionsFY13_14$Bridge == "08" | BridgeTransactionsFY13_14$Bridge == "8"] <- "Benicia-Martinez Bridge"

BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "02" | BridgeTransactionsFY14_15$Bridge == "2"] <- "Antioch Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "03" | BridgeTransactionsFY14_15$Bridge == "3"] <- "Richmond-San Rafael Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "04" | BridgeTransactionsFY14_15$Bridge == "4"] <- "San Francisco-Oakland Bay Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "05" | BridgeTransactionsFY14_15$Bridge == "5"] <- "San Mateo-Hayward Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "06" | BridgeTransactionsFY14_15$Bridge == "6"] <- "Dumbarton Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "07" | BridgeTransactionsFY14_15$Bridge == "7"] <- "Carquinez Bridge"
BridgeTransactionsFY14_15$Bridge[BridgeTransactionsFY14_15$Bridge == "08" | BridgeTransactionsFY14_15$Bridge == "8"] <- "Benicia-Martinez Bridge"

BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "02" | BridgeTransactionsFY15_16$Bridge == "2"] <- "Antioch Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "03" | BridgeTransactionsFY15_16$Bridge == "3"] <- "Richmond-San Rafael Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "04" | BridgeTransactionsFY15_16$Bridge == "4"] <- "San Francisco-Oakland Bay Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "05" | BridgeTransactionsFY15_16$Bridge == "5"] <- "San Mateo-Hayward Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "06" | BridgeTransactionsFY15_16$Bridge == "6"] <- "Dumbarton Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "07" | BridgeTransactionsFY15_16$Bridge == "7"] <- "Carquinez Bridge"
BridgeTransactionsFY15_16$Bridge[BridgeTransactionsFY15_16$Bridge == "08" | BridgeTransactionsFY15_16$Bridge == "8"] <- "Benicia-Martinez Bridge"

BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "02" | BridgeTransactionsFY16_17$Bridge == "2"] <- "Antioch Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "03" | BridgeTransactionsFY16_17$Bridge == "3"] <- "Richmond-San Rafael Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "04" | BridgeTransactionsFY16_17$Bridge == "4"] <- "San Francisco-Oakland Bay Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "05" | BridgeTransactionsFY16_17$Bridge == "5"] <- "San Mateo-Hayward Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "06" | BridgeTransactionsFY16_17$Bridge == "6"] <- "Dumbarton Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "07" | BridgeTransactionsFY16_17$Bridge == "7"] <- "Carquinez Bridge"
BridgeTransactionsFY16_17$Bridge[BridgeTransactionsFY16_17$Bridge == "08" | BridgeTransactionsFY16_17$Bridge == "8"] <- "Benicia-Martinez Bridge"

#bridge selection is intentional--this is the desired output
#Select only BATA Bridges
BridgeTransactions <- sqldf("select * From BridgeTransactions Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")
#Select only BATA Bridges
BridgeTransactionsFY10_13 <- sqldf("select * From BridgeTransactionsFY10_13 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")
BridgeTransactionsFY13_14 <- sqldf("select * From BridgeTransactionsFY13_14 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")
BridgeTransactionsFY14_15 <- sqldf("select * From BridgeTransactionsFY14_15 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")
BridgeTransactionsFY15_16 <- sqldf("select * From BridgeTransactionsFY15_16 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")
BridgeTransactionsFY16_17 <- sqldf("select * From BridgeTransactionsFY16_17 Where Bridge in ('Antioch Bridge','Benicia-Martinez Bridge','Carquinez Bridge','Dumbarton Bridge','Richmond-San Rafael Bridge','San Mateo-Hayward Bridge','San Francisco-Oakland Bay Bridge')")

# End of Fix Bridge Names
###########################################################################################
#Add Year, Month, Day and Weekday columns to dataset
###########################################################################################
BridgeTransactions$xYear <- format(as.Date(BridgeTransactions$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactions$xMonth <-format(as.Date(BridgeTransactions$Date, format="%Y-%m-%d"),"%B")
BridgeTransactions$xDay <- format(as.Date(BridgeTransactions$Date, format="%Y-%m-%d"),"%d")
BridgeTransactions$xWeekday <- format(as.Date(BridgeTransactions$Date, format="%Y-%m-%d"),"%A")

BridgeTransactions_Summary <- aggregate(BridgeTransactions$Transactions, by = list(BridgeTransactions$County, BridgeTransactions$Bridge, BridgeTransactions$FiscalYear, BridgeTransactions$xYear, BridgeTransactions$xMonth, BridgeTransactions$xDay, BridgeTransactions$xWeekday), FUN = sum )
names(BridgeTransactions_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")

#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY10_13$xYear <- format(as.Date(BridgeTransactionsFY10_13$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY10_13$xMonth <-format(as.Date(BridgeTransactionsFY10_13$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY10_13$xDay <- format(as.Date(BridgeTransactionsFY10_13$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY10_13$xWeekday <- format(as.Date(BridgeTransactionsFY10_13$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY10_13_Summary <- aggregate(BridgeTransactionsFY10_13$Transactions, by = list(BridgeTransactionsFY10_13$County, 
                                                                                                 BridgeTransactionsFY10_13$Bridge, 
                                                                                                 BridgeTransactionsFY10_13$FiscalYear, 
                                                                                                 BridgeTransactionsFY10_13$xYear, 
                                                                                                 BridgeTransactionsFY10_13$xMonth, 
                                                                                                 BridgeTransactionsFY10_13$xDay, 
                                                                                                 BridgeTransactionsFY10_13$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY10_13_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")

#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY13_14$xYear <- format(as.Date(BridgeTransactionsFY13_14$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY13_14$xMonth <-format(as.Date(BridgeTransactionsFY13_14$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY13_14$xDay <- format(as.Date(BridgeTransactionsFY13_14$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY13_14$xWeekday <- format(as.Date(BridgeTransactionsFY13_14$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY13_14_Summary <- aggregate(BridgeTransactionsFY13_14$Transactions, 
                                               by = list(BridgeTransactionsFY13_14$County, 
                                                         BridgeTransactionsFY13_14$Bridge, 
                                                         BridgeTransactionsFY13_14$FiscalYear, 
                                                         BridgeTransactionsFY13_14$xYear, 
                                                         BridgeTransactionsFY13_14$xMonth, 
                                                         BridgeTransactionsFY13_14$xDay, 
                                                         BridgeTransactionsFY13_14$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY13_14_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")

#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY14_15$xYear <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY14_15$xMonth <-format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY14_15$xDay <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY14_15$xWeekday <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY14_15_Summary <- aggregate(BridgeTransactionsFY14_15$Transactions, 
                                               by = list(BridgeTransactionsFY14_15$County, 
                                                         BridgeTransactionsFY14_15$Bridge, 
                                                         BridgeTransactionsFY14_15$FiscalYear, 
                                                         BridgeTransactionsFY14_15$xYear, 
                                                         BridgeTransactionsFY14_15$xMonth, 
                                                         BridgeTransactionsFY14_15$xDay, 
                                                         BridgeTransactionsFY14_15$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY14_15_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")

#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY14_15$xYear <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY14_15$xMonth <-format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY14_15$xDay <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY14_15$xWeekday <- format(as.Date(BridgeTransactionsFY14_15$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY14_15_Summary <- aggregate(BridgeTransactionsFY14_15$Transactions, 
                                               by = list(BridgeTransactionsFY14_15$County, 
                                                         BridgeTransactionsFY14_15$Bridge, 
                                                         BridgeTransactionsFY14_15$FiscalYear, 
                                                         BridgeTransactionsFY14_15$xYear, 
                                                         BridgeTransactionsFY14_15$xMonth, 
                                                         BridgeTransactionsFY14_15$xDay, 
                                                         BridgeTransactionsFY14_15$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY14_15_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")
#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY15_16$xYear <- format(as.Date(BridgeTransactionsFY15_16$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY15_16$xMonth <-format(as.Date(BridgeTransactionsFY15_16$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY15_16$xDay <- format(as.Date(BridgeTransactionsFY15_16$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY15_16$xWeekday <- format(as.Date(BridgeTransactionsFY15_16$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY15_16_Summary <- aggregate(BridgeTransactionsFY15_16$Transactions, 
                                               by = list(BridgeTransactionsFY15_16$County, 
                                                         BridgeTransactionsFY15_16$Bridge, 
                                                         BridgeTransactionsFY15_16$FiscalYear, 
                                                         BridgeTransactionsFY15_16$xYear, 
                                                         BridgeTransactionsFY15_16$xMonth, 
                                                         BridgeTransactionsFY15_16$xDay, 
                                                         BridgeTransactionsFY15_16$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY15_16_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")
#Add Year, Month, Day and Weekday columns to dataset
BridgeTransactionsFY16_17$xYear <- format(as.Date(BridgeTransactionsFY16_17$Date, format="%Y-%m-%d"),"%Y")
BridgeTransactionsFY16_17$xMonth <-format(as.Date(BridgeTransactionsFY16_17$Date, format="%Y-%m-%d"),"%B")
BridgeTransactionsFY16_17$xDay <- format(as.Date(BridgeTransactionsFY16_17$Date, format="%Y-%m-%d"),"%d")
BridgeTransactionsFY16_17$xWeekday <- format(as.Date(BridgeTransactionsFY16_17$Date, format="%Y-%m-%d"),"%A")

BridgeTransactionsFY16_17_Summary <- aggregate(BridgeTransactionsFY16_17$Transactions, 
                                               by = list(BridgeTransactionsFY16_17$County, 
                                                         BridgeTransactionsFY16_17$Bridge, 
                                                         BridgeTransactionsFY16_17$FiscalYear, 
                                                         BridgeTransactionsFY16_17$xYear, 
                                                         BridgeTransactionsFY16_17$xMonth, 
                                                         BridgeTransactionsFY16_17$xDay, 
                                                         BridgeTransactionsFY16_17$xWeekday), 
                                               FUN = sum )
names(BridgeTransactionsFY16_17_Summary) <- c("County", "Bridge","FiscalYear","Year","Month", "Day", "Weekday", "Total Transactions")
# End of Date Processes
###########################################################################################
# Export Dataframes to csv
###########################################################################################
write.csv(BridgeTransactions, file = "processed/BridgeTransactions.csv")
write.csv(BridgeTransactions_Summary, file = "processed/BridgeTransactions_Summary.csv")
write.csv(BridgeTransactionsFY10_13, file = "processed/BridgeTransactionsFY10_13.csv")
write.csv(BridgeTransactionsFY13_14, file = "processed/BridgeTransactionsFY13_14.csv")
write.csv(BridgeTransactionsFY14_15, file = "processed/BridgeTransactionsFY14_15.csv")
write.csv(BridgeTransactionsFY15_16, file = "processed/BridgeTransactionsFY15_16.csv")
write.csv(BridgeTransactionsFY16_17, file = "processed/BridgeTransactionsFY16_17.csv")
###########################################################################################