# bridge-transactions
Typical weekday summaries of Bay Area bridge transactions.  For transportation planning purposes, we seek to understand 'typical' weekday behavior, which we define here to occur on non-Holiday Tuesdays, Wednesdays, and Thursdays in the months of March, April, May, September, October, and November.  Methods herein strive to process data provided by the [Bay Area Toll Authority](http://bata.mtc.ca.gov/) to inform estimates of typical weekday travel conditions through time.

Lane designations for the bridges through time is constructed using this [Python script](https://github.com/MetropolitanTransportationCommission/bridge-transactions/blob/6974c83e4c44afa05cd1a0f92e59392e9db84775/Lane%20Designations/Create%20Bridge%20Toll%20Lane%20HOV%20SOV%20Database.ipynb).

The `Consume` directory processes the data and then combines the data into summaries of typical weekdays.  The `Summaries` directory contains a [Tableau workbook](https://github.com/MetropolitanTransportationCommission/bridge-transactions/blob/6974c83e4c44afa05cd1a0f92e59392e9db84775/Summaries/Bridge%20Transactions%20by%20Lane%20Designation.twb) which presents the data; an interactive version of the Tableau workbook is [here](http://analytics.mtc.ca.gov/foswiki/Main/TypicalWeekdayBridgeTransactions). The data is available in the 'bridge-transactions' folder [here](https://mtcdrive.box.com/share-data).


