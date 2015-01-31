# bridge-transactions
Typical weekday summaries of Bay Area bridge transactions.  For transportation planning purposes, we seek to understand 'typical' weekday behavior, which we define here to occur on non-Holiday Tuesdays, Wednesdays, and Thursdays in the months of March, April, May, September, October, and November.  Methods herein strive to process data provided by the [Bay Area Toll Authority](http://bata.mtc.ca.gov/) to inform estimates of typical weekday travel conditions through time.

Lane designations for the bridges through time is constructed using this [Python script](Lane Designations/Create Bridge Toll Lane HOV SOV Database.ipynb).

The `Consume` directory processes the data and then combines the data into typical weekdays statistic.  The `Summaries` directory contains a [Tableau workbook](Summaries/Bridge Transactions by Lane Category.twb) which presents the data; an interactive version of the Tableau workbook is [here](http://analytics.mtc.ca.gov/foswiki/Main/TypicalWeekdayBridgeTransactions). The data is available in the 'bridge-transactions' folder [here](https://mtcdrive.box.com/share-data).



