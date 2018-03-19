# Census API/Data Tools

## Purpose  

This list is intended for people working with Census data in some kind of data management tool--SQL, Python, R etc.

It was last updated in January 2017. Pull Request Welcome! 

## Lists of Available Census APIs 
[Census Official](http://www.census.gov/data/developers/data-sets.html)  
[Secondary, more Detailed Census List in spreadsheet form](http://niaaa.census.gov/data.htm)  

## R Packages
[tidycensus](https://github.com/walkerke/tidycensus)
[tigris](https://github.com/walkerke/tigris)  

These are the go-to packages. 

[acs](https://github.com/cran/acs)   
The functionality of this package seems great--not sure about extensibility. Like the citysdk package, has a massive scope.  

[noncensus](https://github.com/ramhiser/noncensus)   
 
[US-Census 2000](https://cran.r-project.org/web/packages/UScensus2000cdp/index.html)   

## Lists of Variables in each Census Product (e.g. ACS 2014)  

http://api.census.gov/data/2014/acs5/variables.html

## Convert JSON (e.g. from API) to CSV
[convertcsv.com](http://www.convertcsv.com/json-to-csv.ht) 
[json-to-csv](https://konklone.io/json/?id=966b12efc2d0a9f80d6134fe130d0c4) -- [github page for project](https://github.com/konklone/json)  

javascript 
--------------------------
[citysdk](https://github.com/uscensusbureau/citysdk)   
This package has a massively defined scope and seems to be under active development, but its not clear to me how and whether its ready for use.  

python
----------------------
[Census2DBF](https://github.com/fitnr/census2dbf)   
"Converts .csv files downloaded from the [Census Factfinder](http://factfinder2.census.gov/) into the legacy [DBF](http://en.wikipedia.org/wiki/DBase) format, which is useful for GIS applications. Adds a data dictionary to deal with field name issues(short strings)"

[cenpy](https://github.com/ljwolf/cenpy)  
An interface to explore and query the US Census API and return Pandas Dataframes. Ideally, this package is intended for exploratory data analysis and draws inspiration from sqlalchemy-like interfaces and acs.R.  
[example usage](https://gist.github.com/dfolch/2440ba28c2ddf5192ad7)  

[addfips](https://github.com/fitnr/addfips)   
Add a FIPS code to any CSV with a county name in it--seems extensible and useful.   

[census-us](https://github.com/unitedstates/python-us)
Basically, a list of FIPS codes for states--might be useful to have the same for MPOs, in several languages. Seems like in R or Python, it would be useful to just be able to import all the necessary FIPS codes for a query using county and/or city names.  

[census_area](https://pypi.python.org/pypi/census_area/0.2)   
This package has the potential to be useful but requires Shapely and therefore GDAL, which can be annoying to set up.  

[census-wrapper](https://github.com/CommerceDataService/census-wrapper)   

[us_census](https://github.com/linanqiu/us_census)   
[geoid](https://github.com/CivicKnowledge/geoid)   
[get-tiger](https://github.com/fitnr/get-tiger)   



bash
----------------------------
[census-cli](https://github.com/DavidHickman/census-cl)     
"Download 2014 American Community Survey 5-year estimates with population and income linked to a geojson at the tract level for a given zip code"

[tiger](https://github.com/fitnr/get-tiger)   
[census2dbf](https://github.com/fitnr/census2dbf)   
[addfips](https://github.com/fitnr/addfips)   

postgres
------------------------
[census-postgres](https://github.com/leehach/census-postgres)   
This package contains A LOT of work and understanding of the US Census information architecture. Here are a few choice quotes from the readme files in it:

## Flat File Organization:

"Each data product (e.g. American Community Survey 2006-2010) can be thought of as one large file, but the data are horizontally partitioned by state and are vertically separated into "segments" (in the Decennial Census) or "sequences" (in ACS) of less than 256 columns each..."

## Geographic Variables:

"It is expected that analysts will usually be working with data within a geographic scale (e.g. running a regression on county-level data), and often working within a defined region. Scale is identified by two columns, `sumlevel` and `component`, where `sumlevel` represents the level in the geographic hierarchy from Nation to State to County, etc. (and many others such as Tribal Tracts, ZIP Code Tabulation Areas or ZCTAs, Metropolitan and Micropolitan Areas, etc.) and `component` represents a subset of the population in that geography, e.g. Urban only or Rural only population. (The code `00` represents total population, and is often the component of interest. Codes other than `00` are only defined for county and geographies and larger.)"

Rather than require the analyst to constantly filter based on scale, the data may be partitioned by summary level and component. 
 
