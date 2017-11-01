## Housing Permit Geocoding

[Problem Statement](#problem-statement)   
[Data Sources](#data-sources)   
[Methodology](#methodology)   
[Outcome](#outcome)   

### Problem Statement  

Improve the accuracy of the mapped locations for the housing permit database.  

### Data Sources

#### Tables in DB

Housing database (SQL Server).  

The housing permit database is used for the display of information about housing on [this website](http://housing-test.us-west-2.elasticbeanstalk.com/)   

schema_name|table_name|description
------|-----------|------------
dbo|feature_HOLD|temporary table for cartographic checks
dbo|parcels_2015|a table of bay area parcels
dbo|permit|pre-2016 permits
import|Permits_10_18_2017|post 2016 permits

##### table details:  

table: `feature_HOLD`  
Lat,Long,WKT,Shape,gmap_long,gmap_lat,gmap_score
geocoding method: unknownπ

table: `parcels_2015`  
OBJECTID,PARCEL_ID,ACRES,COUNTY_ID,ZONE_ID,APN,X,Y

table: `permit`  
joinid,permyear,permdate,county,jurisdictn,apn,address,zip,projname,hcategory,verylow,low,moderate,abovemod,totalunit,infill,affrdunit,deedaffrd,asstaffrd,opnaffrd,tenure,rpa,rhna,rhnacyc,pda,pdaid,tpa,hoa,occertiss,occertyr,occertdt,mapped,notes

#### Excel Spreadsheets  

[On Box](https://mtcdrive.box.com/s/95h562kecwliig0yp9dkav1neoqw8zbx)  

### Methodology

#### phase 1

Start by updating the geocode results for all addresses (in `permit` table in DB) using Google Maps. 

Scan the db table and find records that do not have a gmap_lat gmap_long and geocode that address and place the results of that match in the table, including its location type. 

[Script here](https://gist.github.com/tombuckley/312f130a87e398f0a2c8af4bb587e02e)

### Outcome  

| description                            | count |   |
|----------------------------------------|-------|---|
| total_permits                          | 19497 |   |
| total_permits_located                  | 19496 |   |
| total_permits_located_outside_bay_area | 1030  |   |

The outcome of Phase 1 is in the housing database on the following tables:  

#### Outcome Table Summary   

schema_name|table_or_view|description
------|-----------|------------
geocoding_summary|all_permits_all_sources|for every permit in `import.Permits_10_18_2017` an xy from each source  
geocoding_summary|main|a summary of the number of geocoded permits 
geocode_spatial_tables|main|`import.Permits_10_18_2017` with best guesses for lat/long  
geocode_spatial_tables|outside_bay_area|view of `main` that is outside the bay area  
import|Permits_10_18_2017|housing permits as processed by KS to add the 2016 collection spreadsheets  
import|rhna_2007_2014|summary of RHNA numbers by jurisdiction for 2007-2014  
import|rhna_2015_2035|summary of RHNA numbers by jurisdiction for 2015-2035  
geocode_results|gmaps_allyears|a view of both gmaps and gmaps_2016 tables  
geocode_results|mapzen_allyears|a view of both mapzen and mapzen_2016 tables  
geocode_results|permitFeature_gmaps|match schema of permitFeature with gmaps lat long for Shape field  
geocode_results|gmaps|location results by service for `address` field in the `permit` table  
geocode_results|mapzen|location results by service for `address` field in the `permit` table  
geocode_results|address_quality_review|location results by service for `address` field in the `permit` table with geocoding results  
geocode_results|old_permits_not_already_geocoded|housing permit records from 2015 or before that didn't previously (before phase 1) have a latitude or longitude  
geocode_results|gmaps_2016|location results by service for `address` field in the `permit_2016_update` table  
geocode_results|mapzen_2016|location results by service for `address` field in the `permit_2016_update` table  




