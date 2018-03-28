# Summarize Lane Information in TomTom

## Goal

Output summary lane information from several TomTom tables. 

## Scripts

- [lanes_summary.sql](lanes_summary.sql) - Used to create a summary view of lanes based on joining a number of TomTom table together on GISDB3
- [lanes_summary.R](lanes_summary.R) - Executes the SQL above, and pulls the data to group by and union geometries, then output main table and data samples for Alameda and San Ramon. 

## Environment

[MTC R Studio Server AMI](https://console.aws.amazon.com/ec2/home?region=us-east-2#launchAmi=ami-318c1249)

## Outcome

### Sample Data and Maps

Sample data are provided below, with an example map.

[Map - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/item.html?id=21c03d5f81164bd89b1578dd25785d85)
[Feature Class - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/item.html?id=bb0ef42996ff483c9fa2cfc44c981c9c)
[Feature Class - Sample 2 - San Ramon](http://mtc.maps.arcgis.com/home/item.html?id=01eddb82b12b4682927a0e25e373e49e)

#### Metadata 

Descriptions of column names and uses can be found in the documentation below:

[Roads](https://mtcdrive.box.com/s/e8g0xuyr8w1pa69d9fcoc8usm6hfpe0j)
[Routing](https://mtcdrive.box.com/s/wdtp9k3rtjnx694fhn0avlccu9xf7kiz)

### All Data

For convenience, all data (including full network) are in [this box folder](https://mtcdrive.box.com/s/ea0xvmnujakz6iwtu42iz755jflknjrs)
