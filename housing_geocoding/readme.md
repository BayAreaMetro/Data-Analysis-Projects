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

- [Location Data](http://mtc.maps.arcgis.com/home/item.html?id=6b7c7052ef46421ca4054cf9f32ed074)  
- [Attribute Data](http://mtc.maps.arcgis.com/home/item.html?id=711a0f06cfd84b8fbe226cc6917d0765)  

#### Location Data Sources

- [Assessor's Parcels 2010 & 2015](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/postgis-parcels/readme.md)
- Assessors websites   
- [Geocoder](https://github.com/DenisCarriere/geocoder)      

#### Administrative Data Sources   

- [Transit Priority Areas](http://mtc.maps.arcgis.com/home/item.html?id=1166cf1467404cf38d0fd6f587f2295f)
- [Priority Development Areas](http://mtc.maps.arcgis.com/home/item.html?id=09e8dbc3a1284acba6340cbdf9ac88d1) 
- [Housing Element Sites 2015-2023](http://mtc.maps.arcgis.com/home/item.html?id=1b452ceb06dd426984665dadefa16e33) 
- [Housing Element Sites 2007-2014](http://mtc.maps.arcgis.com/home/item.html?id=4f8a1d2c0cfd4c878dc3435b27c4a624) 

### Methodology

In practice, we actually did Phase 2 first, but we don't recommend that going forward.  

#### Phase 1 - Data Cleanup  

[Housing_Permit_Data_Exploration.R](/housing_geocoding/R/Housing_Permit_Data_Exploration.R) is how we cleaned and combined all data before starting anything else.  

That script takes the [9 County spreadsheets](https://mtcdrive.box.com/s/8u764glqse2ktnwxkqse9n6cw6tp3hcl) and places columns in the same order as well as fixing a few apparent cut and paste errors in important fields like Zip code and/or Address.  

It also combines the 2015 Collection data with the 2016 Collection data.  

#### Phase 2 - APN/Parcel Search

Use the APN on the permits to locate a [Point on Surface](https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/stpointonsurface-geometry-data-type) for every permit. 

We did this on gisdb3 using a script like [this](/housing_geocoding/sql/find_point_on_surface_with_apn_search.sql), for both 2010 and 2015 parcel data. 

In the future, we recommend using another database.  

[Here](/postgis-parcels/readme.md) we describe how to set up a docker container with postgis that provides the same functionality. 

#### Phase 3 - Address Search   

Update the location for all permit addresses using Google Maps. 

Use the functions in [this script](/housing_geocoding/gcpd/gcpd.py) to geocode records in the SQL server tables, and pull out whatever information you might want from the geocoder such as accuracy or formatted addresses. These scripts assume you have already set up a local adapter for SQL Server and that your python environment is setup to interact with it. Some limited notes on this can be found at the top of [this script](/housing_geocoding/gcpd/gcpd.py). 

There are a number of examples for how to use the functions in [the examples directory](/housing_geocoding/gcpd/examples/). Pull requests welcome! :)

#### Phase 4 - Assessor Website search  

Asessor websites will contain many of the locations for the most recently permitted sites. For all unlocated permits, we located them by combing through Assessor's websites end entering the XY on a map. We used our own tool do enter the XY's. 

#### Phase 5 - Put the APN, Address and Manual results together in 1 table  

We did this using SQL Views. Since we did multiple rounds of review, our views are more complicated than you need, but they are available [here](/housing_geocoding/sql/location.sql)

#### Phase 6 - Write summary tables

We wrote some views to make table-making in Tableau easier--casting (int) years to dates, for example.  

See [here](/housing_geocoding/sql/analysis.sql)   

#### Proposals for Future Work

It would be ideal for this process to be executed via 1 script, whether thats a Makefile, an R script, or a Python script. R is probably the easiest. 

