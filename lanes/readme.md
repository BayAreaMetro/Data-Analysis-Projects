# Summarize Lane Information in TomTom

## Goal

Output summary lane information from several TomTom tables. 

## Scripts

- [lanes_summary.sql](lanes_summary.sql) - Used to create a summary view of lanes based on joining a number of TomTom table together on GISDB3
- [lanes_summary.R](lanes_summary.R) - Executes the SQL above, and pulls the data to group by and union geometries, then output main table and data samples for Alameda and San Ramon. 
- [lanes_summary_by_tmc.sql](lanes_summary.sql) - Used to create a summary view of lanes based on joining a number of TomTom table together on GISDB3
- [lanes_summary_tmcid.R](lanes_summary.R) - Executes the SQL above, and pulls the data to group by and union geometries, then output main table and data samples for Alameda and San Ramon. 

## Environment

[MTC R Studio Server AMI](https://console.aws.amazon.com/ec2/home?region=us-west-2#launchAmi=ami-2dfa6155)

## Outcome

### Data and Maps

Sample data are provided below, with an example map.

#### Road Segments Grouped by Attributes

- [Map - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/item.html?id=21c03d5f81164bd89b1578dd25785d85)
- [FileGDB-Geospatial-Full Network](https://mtcdrive.box.com/s/s8widz2ag2v9umk8of45ost73116qlb9)
- [Feature Class - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/item.html?id=bb0ef42996ff483c9fa2cfc44c981c9c)
- [Feature Class - Sample 2 - San Ramon](http://mtc.maps.arcgis.com/home/item.html?id=01eddb82b12b4682927a0e25e373e49e)

#### Road Segments Grouped by TMCID 

- [CSV File-Attributes Only](https://mtcdrive.box.com/s/gly2zcjo5abj5ow02wsuosla77lmzue9)

**Provide a description of the key attributes in this file**

- [FileGDB-Geospatial-Full Network](https://mtcdrive.box.com/s/swt592xtohzoh7o0l6gktyvlrrxry8og)
- [Feature Class - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/item.html?id=ccdeea77c66242c881aed3869d228510)
- [Feature Class - Sample 2 - San Ramon](http://mtc.maps.arcgis.com/home/item.html?id=e4bc7f1246b7435e93c28aa3d17ae438)

#### Metadata 

Descriptions of column names and uses can be found in the documentation below:

##### Summary by Attribute

- [Detailed Data Dictionary (select attributes](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/lanes/detailed_lanes_data_dictionary.md)
- [Data Dictionary](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/lanes/lanes_data_dictionary.csv) - Brief descriptions of the field names in the table below 

##### Detailed TomTom Documents 
- [Roads](https://mtcdrive.box.com/s/e8g0xuyr8w1pa69d9fcoc8usm6hfpe0j)
- [Routing](https://mtcdrive.box.com/s/wdtp9k3rtjnx694fhn0avlccu9xf7kiz)


### All Data

For convenience, all data (including full network) are in [this box folder](https://mtcdrive.box.com/s/ea0xvmnujakz6iwtu42iz755jflknjrs)
