Get May 2018 VTA Expresslane data
================

-   [Goal](#goal)
-   [Methods](#methods)
-   [Outcome](#outcome)

Goal
----

Get one month's worth of this VTA toll price data (e.g. May 2018)

Methods
-------

``` r
library(clpr)
library(dplyr)
library(readr)
library(lubridate)
source("~/.keys/rs.R")
rs <- connect_rs()
```

Get the data.

``` sql
SELECT pricing_module,
message_module,
convert_timezone('US/Pacific', time_checked) as time_checked,
algorithm_mode, facility_id,
interval_starting
FROM "public"."vta_expresslanes_toll_status"
where time_checked >= '05-01-2018'
and time_checked < '06-01-2018'
```

Make date and time nice to read.

``` r
exln$hour <- hour(exln$time_checked)
exln$minute <- minute(exln$time_checked)
exln$mday <- mday(exln$time_checked)
exln$wday <- wday(exln$time_checked)
knitr::kable(sample_n(exln,5))
```

|      | pricing\_module | message\_module | time\_checked       | algorithm\_mode | facility\_id |  interval\_starting|  hour|  minute|  mday|  wday|
|------|:----------------|:----------------|:--------------------|:----------------|:-------------|-------------------:|-----:|-------:|-----:|-----:|
| 3129 | 0.50            | HOV 2+ NO TOLL  | 2018-05-04 08:37:53 | EL Speed        | FSE          |          1525448100|     8|      37|     4|     6|
| 2165 | 0.50            | HOV 2+ NO TOLL  | 2018-05-07 15:22:53 | EL Speed        | CLW          |          1525731600|    15|      22|     7|     2|
| 1866 |                 | OPEN TO ALL     | 2018-05-04 02:42:53 |                 | FSE          |          1525426800|     2|      42|     4|     6|
| 3904 |                 | OPEN TO ALL     | 2018-05-07 03:32:53 |                 | FSE          |          1525689000|     3|      32|     7|     2|
| 1906 |                 | OPEN TO ALL     | 2018-05-03 13:47:53 |                 | FSE          |          1525380300|    13|      47|     3|     5|

Heads up check on time/pricing.

``` r
plot(exln$hour,exln$pricing_module)
```

![](readme_files/figure-markdown_github/unnamed-chunk-4-1.png)

``` r
write_csv(exln,"may_2018_vta_expresslane_status.csv")
```

Outcome
-------

[may\_2018\_vta\_expresslane\_status.csv](may_2018_vta_expresslane_status.csv)
