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

To locate permitted projects not located through afforementioned geocoding processes, we relied on Assessor websites or Planning and Development Department websites to obtain information. All county sites offered interactive parcel lookup tools which provided the spatial information necessary to manually geocode remaining permitted projects using our in-house mapping tool called [Project Mapper](http://project-mapper.us-west-2.elasticbeanstalk.com/). The interactive parcel lookup tools are listed below by county. 

- [Alameda County Parcel Lookup](http://gis.acgov.org/Html5Viewer/index.html?viewer=parcel_viewer)
- [Contra Costa County Parcel Lookup](https://ccmap.cccounty.us/Html5/index.html?viewer=CCMAP)
- [Marin County Parcel Lookup](https://www.marinmap.org/Html5Viewer/Index.html?viewer=smmdataviewer) 
- [Napa County Parcel Lookup](http://gis.napa.ca.gov/Html5Viewer/Index.html?viewer=Public_HTML)
- [San Francisco County Parcel Lookup](http://propertymap.sfplanning.org/)
- [San Mateo County Parcel Lookup](http://maps.smcgov.org/GE_4_4_0_Html5Viewer_2_5_0_public/?viewer=raster)
- [Santa Clara County Parcel Lookup](http://www.sccpropertyinfo.org/)
- [Sonoma County Parcel Lookup](http://imsportal.sonoma-county.org/ActiveMap/)

#### Put the APN, Address and Manual results together in 1 table  

We did this using SQL Views. Since we did multiple rounds of review, our views are more complicated than you need, but they are available [here](/housing_geocoding/sql/location.sql)

#### Write summary tables

We wrote some views to make table-making in Tableau easier--casting (int) years to dates, for example.  

See [here](/housing_geocoding/sql/analysis.sql)   

#### Proposals for Future Work

It would be ideal for this process to be executed via 1 script, whether thats a Makefile, an R script, or a Python script. R is probably the easiest. 

#### Analytical work

##### Housing Elements Analysis

load the data into the db:

```
shp2pgsql -s EPSG:4326 data/Regional_Housing_Need_Assessment_20072014__Housing_Element_Sites/Regional_Housing_Need_Assessment_20072014__Housing_Element_Sites.shp | psql -h localhost -d analysis_scratch -U tom
shp2pgsql -s EPSG:4326 data/Regional_Housing_Need_Assessment_20152023__Housing_Element_Sites/Regional_Housing_Need_Assessment_20152023__Housing_Element_Sites.shp | psql -h localhost -d analysis_scratch -U tom
```

