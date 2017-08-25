setwd("~/Documents/Projects/bridge-transactions/Two-Bridge-Users")
library(readxl)
library(dplyr)
library(lubridate)
library(knitr)
library(reshape2)
source("two_bridge_functions.R")

#download the data here: https://mtcdrive.box.com/s/y9i8w9voz2okobxn7dbqj0twrl4rmqqs
#received from ray j on 08/22/2017
rj_path <- "Aug14_2017sfobbetc.xlsx"

df_rj <- read_excel(rj_path, sheet=1)

#received from rebecca l on 07/19/2017 (provided by beth z)
#download the data here: https://mtcdrive.box.com/s/kt0j8z0lgpbw7yu6g7jareevi9nyata2
df1 <- read_excel("TwoBridgeData.xlsx", sheet=1)
df2 <- read_excel("TwoBridgeData.xlsx", sheet=2)
df3 <- read_excel("TwoBridgeData.xlsx", sheet=3)
#the third tab has 4 fewer columns 
df_bz <- bind_rows(df1,df2,df3)

ftr_04_12_2017_commute <- transactions_to_bridge_users_bz(df_bz, commute=TRUE)
ftr_08_14_2017_commute <- transactions_to_bridge_users_rj(df_rj, commute=TRUE)

ftr_04_12_2017_all_hours <- transactions_to_bridge_users_bz(df_bz, commute=FALSE)
ftr_08_14_2017_all_hours <- transactions_to_bridge_users_rj(df_rj, commute=FALSE)

#write data out
library(readr)
write_excel_csv(ftr_08_14_2017_commute$devices_bridges,"08_14_2017_devices_by_bridge_commute.csv")
write_excel_csv(ftr_08_14_2017_commute$summary_two_bridge,"08_14_2017_commute_summary_table.csv")

write_excel_csv(ftr_08_14_2017_all_hours$devices_bridges,"08_14_2017_devices_by_bridge_all_hours.csv")
write_excel_csv(ftr_08_14_2017_all_hours$summary_two_bridge,"08_14_2017_all_hours_summary_table.csv")

write_excel_csv(ftr_04_12_2017_commute$devices_bridges,"04_12_2017_devices_by_bridge_commute.csv")
write_excel_csv(ftr_04_12_2017_commute$summary_two_bridge,"04_12_2017_commute_summary.csv")

write_excel_csv(ftr_04_12_2017_all_hours$devices_bridges,"04_12_2017_devices_by_bridge_all_hours.csv")
write_excel_csv(ftr_04_12_2017_all_hours$summary_two_bridge,"04_12_2017_all_hours_summary.csv")

