
#takes formatted time string
#returns an interval for filtering
format_rj_time <- function(df_transactions_time) {
  txn_time <-as.POSIXct(df_transactions_time,format="%Y:%m:%d %H:%M:%S")
  library(hms)
  txn_hms <- as.hms(txn_time)
  library(lubridate)
  txn_time_interval <- hms(txn_hms)
  return(txn_time)
}

format_bz_time <- function(df_transaction_time) {
  txn_time <-as.POSIXct(df_transaction_time,format="%H:%M:%S")
  library(hms)
  txn_hms <- as.hms(txn_time)
  library(lubridate)
  txn_time_interval <- hms(txn_hms)
  return(txn_time)
}

#takes a dataframe of user transactions by bridge
#returns a count per user of the number of distinct bridges crossed
count_distinct_bridges_crossed <- function(df_transactions) {
  df_dvc_bool <- data.frame(apply(df_transactions[,2:length(df_transactions)],2,as.logical))
  head(df_dvc_bool)
  distinct_bridges_crossed <- apply(df_dvc_bool[,1:length(df_dvc_bool)],
                                    1,
                                    sum)
  return(distinct_bridges_crossed)  
}

#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]

  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }

  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions

  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}

#takes a bz formatted dataframe 
#returns 2x summary and devices by bridge summary
transactions_to_bridge_users_bz <- function(tt, commute) {
  ftr <- list()
  
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(tt)[1]
  devices$total <- length(unique(tt$DEVICE_NO))
  
  #fares
  tt$big_fares <- tt$FULL_FARE_AMOUNT > 6
  transactions$bigfares <- table(tt$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((tt[tt$big_fares=="TRUE",])$DEVICE_NO))
  
  #drop big fare transactions
  tt <- tt[!tt$big_fares,]
  
  if(commute == TRUE){
    tt$txn_time_interval <- format_bz_time(tt$`Txn Time`)
    
    tt$am_commute <- hour(tt$txn_time_interval) >= 5 & hour(tt$txn_time_interval) < 10
    tt$pm_commute <- hour(tt$txn_time_interval) >= 15 & hour(tt$txn_time_interval) < 19
    
    transactions$commute <- table(tt$am_commute | tt$pm_commute)[["TRUE"]]
    transactions$noncommute <- table(tt$am_commute | tt$pm_commute)[["FALSE"]]
    
    devices$commute <- length(unique((tt[tt$am_commute | tt$pm_commute,])$DEVICE_NO))
    devices$noncommute <- length(unique((tt[!(tt$am_commute | tt$pm_commute),])$DEVICE_NO))
    
    #check 
    transactions$noncommute + transactions$commute + transactions$bigfares
    
    #drop transactions by time
    dropped_transactions <- !(tt$am_commute | tt$pm_commute)
    tt <- tt[!dropped_transactions,]
    
    #check
    dim(tt)[1] == transactions$commute
  }
  
  #summarize bridge crossings by DEVICE_NO
  df_dvc <- dcast(tt,DEVICE_NO~PLAZA_ABBR)
  
  #warninghere worried me a bit on a second check, so checking again
  #want to confirm that its not just pm_commute==TRUE
  #i think not, b/c of length not sum
  
  tt$transaction_count <- 1
  df_dvc_check <- dcast(tt,DEVICE_NO~PLAZA_ABBR, value.var="transaction_count", fun.aggregate = sum)
  
  #sums of both are equal, so warning is not a problem
  sum(df_dvc_check[,2:8]) == sum(df_dvc[,2:8])
  
  #check that the number of transactions in this matrix equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(tt)[1]
  
  #check whether 2 distinct bridges are crossed
  df_dvc2 <- data.frame(apply(df_dvc[,2:length(df_dvc)],2,as.logical))
  
  distinct_bridge_crossed <- apply(df_dvc2[,1:length(df_dvc2)],1,sum)
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  df_dvc$total_transactions <- total_transactions

  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #write summary table
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}

#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#had to#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #fares
  df_transactions$big_fares <- df_transactions$smRevenueExpected > 6
  transactions$bigfares <- table(df_transactions$big_fares)[["TRUE"]]
  devices$bigfares <- length(unique((df_transactions[df_transactions$big_fares=="TRUE",])$biTagNumber))
  
  head(transactions)
  head(devices)
  
  # no zero fares in this data set
  # df_transactions$zero_fares <- df_transactions$smRevenueExpected == 0
  # transactions$zero_fares <- table(df_transactions$zero_fares)[["TRUE"]]
  # devices$zero_fares <- length(unique((df_transactions[df_transactions$zero_fares=="TRUE",])$biTagNumber))
  
  #drop big fare transactions
  df_transactions <- df_transactions[!df_transactions$big_fares,]
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]
  
  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }
  
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  head(df_dvc)
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1]
  
  #visual check on transaction count
  head(df_dvc[df_dvc$total_transactions>1,])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}

#takes a dataframe of RJ style transactions
#filters and returns a list containing the following data frames:
#1) a count of transactions by bridge for each user
#3) a summary of the number of users crossing 2 distinct bridges in a day
transactions_to_bridge_users_rj2 <- function(df_transactions, commute) {
  ftr <- list()
  #setup up summary table
  devices <- c()
  transactions <- c()
  
  dropped_transactions <- (df_transactions$biTagNumber==0)
  df_transactions <- df_transactions[!dropped_transactions,]
  
  transactions$total <- dim(df_transactions)[1]
  devices$total <- length(unique(df_transactions$biTagNumber))
  
  #flag commute time transactions
  df_transactions$txn_time <- format_rj_time(df_transactions$`dtTransDateTime`)
  df_transactions$am_commute <- hour(df_transactions$txn_time) >= 5 & hour(df_transactions$txn_time) < 10
  df_transactions$pm_commute <- hour(df_transactions$txn_time) >= 15 & hour(df_transactions$txn_time) < 19
  
  #update summary table
  devices$commute <- length(unique((df_transactions[df_transactions$am_commute | df_transactions$pm_commute,])$biTagNumber))
  devices$noncommute <- length(unique((df_transactions[!(df_transactions$am_commute | df_transactions$pm_commute),])$biTagNumber))
  transactions$commute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["TRUE"]]
  transactions$noncommute <- table(df_transactions$am_commute | df_transactions$pm_commute)[["FALSE"]]

  if(commute == TRUE){
    #drop non-cummute from transactions table
    dropped_transactions <- !(df_transactions$am_commute | df_transactions$pm_commute)
    df_transactions <- df_transactions[!dropped_transactions,]
    
    #check that the drop didn't lose any commute transactions
    dim(df_transactions)[1] == transactions$commute
  }

  #check that the drop didn't lose any commute transactions
  print(dim(df_transactions)[1] == transactions$commute)
    
  library(reshape2)
  #summarize bridge crossings by biTagNumber
  df_transactions$transaction_count <- 1
  df_dvc <- dcast(df_transactions,biTagNumber~iPlazaID, length, value.var="transaction_count")
  
  #check that the number of transactions in this dataframe (by bridge) equal those in the total set
  print(sum(df_dvc[,2:length(df_dvc)]) == dim(df_transactions)[1])
  
  #sum distinct bridges per user--wait to assign until after summing transactions on the df below
  distinct_bridge_crossed <- count_distinct_bridges_crossed(df_dvc)
  
  #sum total transactions per user
  total_transactions <- apply(df_dvc[,2:length(df_dvc)],1,sum)
  df_dvc$total_transactions <- total_transactions
  
  #assign sum of distinct bridges per user to the df
  df_dvc$distinct_bridge_crossed <- distinct_bridge_crossed
  
  df_dvc$discounted_transactions <- as.numeric(df_dvc$distinct_bridge_crossed>1)*(df_dvc$total_transactions-1)
  
  #update summaries
  transactions$total_discounted_transactions <- sum(df_dvc$discounted_transactions)
  transactions$total_for_two_distinct_bridge_users <- sum(df_dvc[df_dvc$distinct_bridge_crossed>1,]$total_transactions)
  devices$crossing_two_distinct_bridges <- dim(df_dvc[df_dvc$distinct_bridge_crossed>1,])[1]
  
  #format summary table as dataframe
  l1 <- list(transactions=transactions,devices=devices)
  l <- melt(l1)
  dfs <- dcast(l, L1 ~ L2)
  
  ftr$devices_bridges <- df_dvc
  ftr$summary_two_bridge <- dfs
  return(ftr)
}


