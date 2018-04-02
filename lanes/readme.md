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

*See Metadata links for attribute descriptions*
- [Map - Sample 1 - Oakland/Emeryville](http://mtc.maps.arcgis.com/home/webmap/viewer.html?webmap=a1021afbcc904557b038c59a8b983346)
- [FileGDB-Geospatial-Full Network](https://mtcdrive.box.com/s/s8widz2ag2v9umk8of45ost73116qlb9)

#### Road Segments Grouped by TMCID 

*See Metadata links for attribute descriptions*
- [Excel File-Attributes Only](https://mtcdrive.box.com/s/9owxcra21xoq7smqask4u65pn2ibbqzr)

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
