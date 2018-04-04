# Summarize Road Network Information in TomTom

## Data Sources

- [TomTom 2016/12 Data](https://github.com/BayAreaMetro/DataServices/tree/master/TomTom%20Base%20Map). 
- [Freeway TMC List](https://mtcdrive.box.com/s/u4xs9976gq1ga1qiofj5vj5dfewgfj8i). 

## Scripts

### Lanes Summary grouped by Attributes

- [lanes_summary.sql](lanes_summary.sql) - Summarize number of lanes, average speed, and other variables for road networks
- [lanes_summary.R](lanes_summary.R) - Summarize number of lanes, average speed, and other variables on road networks

#### Lanes Summary Grouped by TMCID 

- [lanes_summary_tmcid.R](lanes_summary.R) - Summarize number of lanes, average speed, and other variables by TMC ID
- [lanes_summary_by_tmc.sql](lanes_summary.sql) - Summarize number of lanes, average speed, and other variables by TMC ID 

#### Speed Limit Summary grouped by TMCID 

- [speed_limit_summary.R](speed_limit_summary.R) - Summarize speed limits by TMC ID
- [speed_limit_summary.sql](speed_limit_summary.sql) - Summarize speed limits by TMC ID
- [make_route_id_to_tmc_to_speed_limit_lookup.R](make_route_id_to_tmc_to_speed_limit_lookup.R) - Join TMC speed limit data to Highway Route ID's

## Environment

[MTC R Studio Server AMI](https://console.aws.amazon.com/ec2/home?region=us-west-2#launchAmi=ami-2dfa6155)

## Outcome

### Data and Maps

Sample data are provided below, with an example map.

#### Lanes Summary grouped by Attributes

*See Metadata links for attribute descriptions*
- [Map - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/webmap/viewer.html?webmap=a1021afbcc904557b038c59a8b983346)
- [FileGDB-Geospatial-Full Network](https://mtcdrive.box.com/s/s8widz2ag2v9umk8of45ost73116qlb9)

#### Lanes Summary Grouped by TMCID 

*See Metadata links for attribute descriptions*
- [Excel File-Attributes Only](https://mtcdrive.box.com/s/9owxcra21xoq7smqask4u65pn2ibbqzr)

#### Speed Limit Summary grouped by TMCID 

*See detailed description in metadata section attribute descriptions*
- [Excel File-Attributes Only](https://mtcdrive.box.com/s/l3d4hsp3urua9ujacuhv6y20cf8pn0ic)

#### Metadata 

Descriptions of column names and uses can be found in the documentation below:

##### Summary by Attribute

- [Summary Data Dictionary](lanes_data_dictionary.csv) - Brief descriptions of the field names in the table below 
- [Detailed Data Dictionary](detailed_lanes_data_dictionary.md) - A selection of more detailed descriptions. Please see the detailed docs for more details below. 

##### Detailed TomTom Documents 
- [Roads](https://mtcdrive.box.com/s/e8g0xuyr8w1pa69d9fcoc8usm6hfpe0j)
- [Routing](https://mtcdrive.box.com/s/wdtp9k3rtjnx694fhn0avlccu9xf7kiz)

### All Data

For convenience, all data (including full network) are in [this box folder](https://mtcdrive.box.com/s/ea0xvmnujakz6iwtu42iz755jflknjrs)
