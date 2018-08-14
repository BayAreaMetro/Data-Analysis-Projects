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
where convert_timezone('US/Pacific', time_checked) >= '05-01-2018'
and convert_timezone('US/Pacific', time_checked) < '06-01-2018'
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
| 533  |                 | OPEN TO ALL     | 2018-05-06 13:27:53 |                 | FSE          |          1525638300|    13|      27|     6|     1|
| 2940 | 8.00            | HOV 2+ NO TOLL  | 2018-05-02 09:17:53 | EL Speed        | CLW          |          1525277700|     9|      17|     2|     4|
| 2376 |                 | OPEN TO ALL     | 2018-05-06 06:47:53 |                 | CLW          |          1525614300|     6|      47|     6|     1|
| 3506 |                 | OPEN TO ALL     | 2018-05-05 17:22:53 |                 | CLW          |          1525566000|    17|      22|     5|     7|
| 3168 | 1.00            | HOV 2+ NO TOLL  | 2018-05-03 18:12:53 | EL Speed        | CLW          |          1525396200|    18|      12|     3|     5|

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
