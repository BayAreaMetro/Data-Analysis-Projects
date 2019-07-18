# Documentation
Geospatial procedure and tabular analysis of INRIX-based congested roadway XD segments in the Bay Area.  

### Define the Problem Statement  

Where are the most congested Bay Area roadways? What are the vehicle hours of delay? Are the congested segments different at different times of the day?  

### Project Management 

- [Asana Project](https://app.asana.com/0/412103232252676/1128376588486927) 
- [Box](https://mtcdrive.box.com/s/j4qnkfwupq1xvsuwzpuyirzp3x4bolup)

### Contents 

- [Data Sources](#data-sources)
- [Analysis Parameters](#analysis-parameters)
- [Methodology](#methodology)
- [Expected Outcomes](#expected-outcomes)
- [Results](#results)

## Data Sources  

- [congested segments excel document](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/congested_segments/2018/data/2018-Weekday-Summary.xlsx) - this is derived from INRIX data by MTC operations.  

- [Spatial Data](https://inrix.sharepoint.com/:f:/g/Sales/Sales_Engineering/EhLr_r3avPFKgNhpMNb2X9IBXFW-2SmjmqKqIxbEoAgK9g?e=PT30Ht) - We pull this directly from INRIX: United_States__California_shapefile.zip.
 
## Analysis Parameters  
  

## Methodology  

1.  
2.  
3. 
4. 

## Expected Outcomes

An interactive AGOL web map showcasing only Bay Area Disadvantaged Communities based on the [CalEnviroScreen 3.0](https://oehha.ca.gov/calenviroscreen/report/calenviroscreen-30) data contcreated by the [Office of Environmental Health Hazard Assessment (OEHHA)](https://oehha.ca.gov/).  


## Final Tabular Data Results  

Percentile Range ('CES_3_0Pctl_Range2018') greater than 75%

| Bay Area Counties  	| 2010 Total Population | 
|-----------------------|-----------------------|
| Alameda               | 148,268           	| 
| Contra Costa	 	 	| 140,335	            | 
| Marin	 	 	        | 0	                    | 
| Napa                  | 0 	                | 
| San Francisco	 	 	| 43,189                |  
| San Mateo	 	        | 34,954	            | 
| Santa Clara           | 71,936                | 
| Solano    	 	 	| 17,287 	            | 
| Sonoma 	 	        | 7,522	                | 
| Regional total        | 463,491               | 


### Final Web Map Data Results  

[Bay Area DACs](https://mtc.maps.arcgis.com/home/webmap/viewer.html?webmap=fb249db7b20644f7b94ecd8a0d8c2207&extent=-124.0323,37.1176,-120.6567,38.5514)  





####old
# Goal 

Using methods developed in [2016](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/tree/a12f64779e17d3d19cebb5657ff50afa90d2b195/congested_segments/2016), linke congested segments spreadsheets to cartographic information on roads from TomTom Data.  

# Data Sources

- [congested segments excel document](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/congested_segments/2017/data/WeekdayCongestedSegmentsList_2017_v2.xlsx) - this is derived from INRIX data by MTC operations.  
- [TomTom Data](http://gis.mtc.ca.gov/home/tomtom.html) - We pull this directly from an existing DB in the scripts below. 

# Method

Use idioms in [congested_segments.R](congested_segments.R) and [congested_segments.sql](congested_segments.sql) to pull segments based on the TMC link between the two data sets. 

# Outcome

- [cs17.geojson](cs17.geojson) - congested segments identified as above.  
- [congested_segments_map17.html](congested_segments_map17.html) - bundled html/js interactive leaflet map of the segments - view as interactive map [here](https://cdn.rawgit.com/BayAreaMetro/Data-And-Visualization-Projects/master/congested_segments/2017/congested_segments_map17.html)
