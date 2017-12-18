## Housing Permit Geocoding

[Problem Statement](#problem-statement)   
[Data Sources](#data-sources)   
[Methodology](#methodology)   
[Outcome](#outcome)   

### Problem Statement  

Locate permitted affordable housing and flag whether they are within Priority Development and/or Transit Priority Areas.    

### Data Sources

#### Permits

Metadata details are in the permitDataDictionary table on the web application database.   

##### 2016 Collection

- [Source Data by County](https://mtcdrive.box.com/s/8u764glqse2ktnwxkqse9n6cw6tp3hcl)  

##### 2015 Collection

- [Location Data](http://opendata.mtc.ca.gov/datasets/residential-building-permits-features)  
- [Attribute Data](http://opendata.mtc.ca.gov/datasets/residential-building-permits-attributes)  

#### Location Data Sources

- [Assessor's Parcels 2010 & 2015](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/postgis-parcels/readme.md)
- Assessors websites  

#### Administrative Data Sources   

- [Transit Priority Areas](http://opendata.mtc.ca.gov/datasets/transit-priority-areas-2017)
- [Priority Development Areas](http://opendata.mtc.ca.gov/datasets/priority-development-areas-current) 
- [Housing Element Sites 2015-2023](http://opendata.mtc.ca.gov/datasets/regional-housing-need-assessment-2015-2023-housing-element-sites) 
- [Housing Element Sites 2007-2014](http://opendata.mtc.ca.gov/datasets/regional-housing-need-assessment-2007-2014-housing-element-sites) 

### Methodology

The headings below are listed in the order of processing that makes the most sense based on going through this process, although we did some of them in different orders the first time around.  

#### Download Data

Download all the data listed above. We use a subdirectory in this folder called 'data'.  

#### Data Cleanup  

Input: The [9 County spreadsheets](https://mtcdrive.box.com/s/8u764glqse2ktnwxkqse9n6cw6tp3hcl). 

Output: [Permits2016.csv](/housing_geocoding/data/Permits2016.csv) 

Script: Use [scrub_2016_permits.R](/housing_geocoding/R/scrub_2016_permits.R) to clean the 2016 data.    

Optionally, use [summarize_2015_and_2016_permits.R](/housing_geocoding/R/summarize_2015_and_2016_permits.R) to join the 2015 and 2016 data and summarize it.   

Environment: R Studio/tidyverse  

#### APN/Parcel Search

Input: [Permits2016.csv](/housing_geocoding/data/Permits2016.csv) scrubbed by the R script. Parcel data. 

Outputs: 
- [apn_centroids.csv](/housing_geocoding/data/apn_centroids.csv) - about 2763 records with parcel APN's found in 2010 or 2015.  
- [to_geocode.csv](/housing_geocoding/data/to_geocode.csv) - about 4441 records with no APN match, needing geocode. 

Script: Use the APN on the permits to locate a [Point on Surface](https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/stpointonsurface-geometry-data-type) for every permit. 

You can use [this](/housing_geocoding/sql/find_point_on_surface_with_apn_search.sql) script to do so.

Environment: PostGIS. [Here](/postgis-parcels/readme.md) we describe how to set up a docker container with parcels. 

#### Address Search   

Update the location for all permit addresses using Google Maps. 

Use the functions in [this script](/housing_geocoding/gcpd/gcpd.py) to geocode records in the SQL server tables, and pull out whatever information you might want from the geocoder such as accuracy or formatted addresses. These scripts assume you have already set up a local adapter for SQL Server and that your python environment is setup to interact with it. Some limited notes on this can be found at the top of [this script](/housing_geocoding/gcpd/gcpd.py). 

There are a number of examples for how to use the functions in [the examples directory](/housing_geocoding/gcpd/examples/). Pull requests welcome! :)

#### Assessor Website search  

Asessor websites will contain many of the locations for the most recently permitted sites. For all unlocated permits, we located them by combing through Assessor's websites end entering the XY on a map. We used our own tool do enter the XY's. 

#### Put the APN, Address and Manual results together in 1 table  

We did this using SQL Views. Since we did multiple rounds of review, our views are more complicated than you need, but they are available [here](/housing_geocoding/sql/location.sql)

#### Write summary tables

We wrote some views to make table-making in Tableau easier--casting (int) years to dates, for example.  

See [here](/housing_geocoding/sql/analysis.sql)   

#### Proposals for Future Work

It would be ideal for this process to be executed via 1 script, whether thats a Makefile, an R script, or a Python script. R is probably the easiest. 

