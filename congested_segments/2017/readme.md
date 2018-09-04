# Goal 

Using methods developed in [2016](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/tree/a12f64779e17d3d19cebb5657ff50afa90d2b195/congested_segments/2016), linke congested segments spreadsheets to cartographic information on roads from TomTom Data.  

# Data Sources

- [congested segments excel document](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/congested_segments/2017/data/WeekdayCongestedSegmentsList_2017_v2.xlsx) - this is derived from INRIX data by MTC operations.  
- [TomTom Data](http://gis.mtc.ca.gov/home/tomtom.html) - We pull this directly from an existing DB in the scripts below. 

# Method

Use idioms in [congested_segments.R](congested_segments.R) and [congested_segments.sql](congested_segments.sql) to pull segments based on the TMC link between the two data sets. 

# Outcome

- [cs17.geojson](cs17.geojson) - congested segments identified as above.  
- [congested_segments_map17.html](congested_segments_map17.html) - bundled html/js interactive leaflet map of the segments
