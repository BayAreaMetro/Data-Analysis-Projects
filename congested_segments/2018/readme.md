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

- [Congested Segments workbook](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/congested_segments/2018/data/2018-Weekday-Summary.xlsx) - this is derived from INRIX data by MTC operations.  
- [Spatial data](https://mtcdrive.box.com/s/bfwavpnsxh9l387u8fo2hb0x94nood7m) - We pull this directly from INRIX: United_States__California_shapefile.zip  
 
## Analysis Parameters  
Identify the 164 most congested roadway segments in the Bay Area by relating a tabular Congested segments workbook with the GIS shapefile spatial data. The output relational dataset will be leveraged in an online map used by a cornerstone MTC program called 'Vital Signs'.  

Identify all XD segments contained in each MTC aggregate corridor. ie. In Alameda County, a corridor location called: W GRAND AVE to EB I-80 contains two xd segments: '1626701618' and '1626750256' while 
the most congested segment in the region: I-280 to WEST OF TREASURE ISLAND contains fifteen XD segments.
## Methodology  

1.  Isolate Bay Area XD segments from USA_California based on the XDsgments in the 'Weekday-2018-Summary.xlsx
2.  Join Weekday-2018_Summary on XDsegment, then try previous_XDsegment then try next_XDsegment

## Expected Outcomes

An [interactive web map](http://www.vitalsigns.mtc.ca.gov/time-spent-congestion) showcasing the most congested roadway segments in the Bay Area.  
[cs2018_v2.shp](cs2018_v2.shp) - congested segments identified as above.  