# vital-signs-traffic-data
Scripts for traffic data

## Problem Statement  

Use TMC codes to fetch geometries for spreadsheets of congestion and traffic data.

## Data Sources

INRIX traffic data.  

### TomTom Geometry Data   

Relevant shapefiles and tables for this project are on the California Shapefiles DVD in the folder: `nam2016_12\shpd\mn\usa\uc3`  

#### table names  

table_abbreviation|table_name
------|------
rd|TMC Information on Road Element  
nw|Network  

Above taken from the UML diagram [here](https://mtcdrive.app.box.com/file/65188361825)    

A full set of table names is [here](https://gist.github.com/tombuckley/2648c8fe9a776e2658d03a76769b07c4)    

#### Variables  

A full set of variable names is [here](https://gist.github.com/tombuckley/130773fd00026069ed4565eb40e1d88f):   

#### TMC Codes:   

"...Level 1 RD attribute of a Road or Ferry Element. This attribute can be retrieved from the rd table's RDSTMC field. This field stores the TMC Location Reference Code as `ABCCDEEEEE.`..."   

Where:  
  
`A` = Direction of Road Element (from start Junction to end Junction) compared with the TMC chain direction:   
`+` = in positive direction and external to the TMC point location;   
`-` = in negative direction and external to the TMC point location;   
`B` = EBU (European Broadcasting Union) Country Code;   
`CC` = TMC Location Code;   
`D` = TMC Direction of the Chain;   
`+` = in positive direction and external to the TMC point location;   
`-` = in negative direction and external to the TMC point location;   
`P` = in positive direction and internal to the TMC point location;   
`N` = in negative direction and internal to the TMC point location.   
`EEEEE` = TMC Point Location Code (found in the official TMC location Databases).   

Example: TMC Location Reference Code in the Shapefile rd table:     

ID|RDSTMC|TMCPATHID  
--|-----|-------  
15280000693470|+817-45896|15280801601246   

## Methodology

Drop the `Direction of Road Element (from start Junction to end Junction) compared with the TMC chain direction` from the `TMC Location Reference Code` on the tomtom `rd` table and then we can join the tomtom geometries to the speed and congestion data.  
  
## Results  

Congested Segments Shapefile:  

https://mtcdrive.box.com/s/t6dmvpogp428wrvwj3juxx95k6qllaqm  

table join success rate: 1134/1139  

data that failed to join: (data/cs_no_geom...csv)  

Average Highway Speeds Shapefile:  

https://mtcdrive.box.com/s/wkc4zjko67qq0epesbw2z4dlgxv6i4s2  

table join success rate: 2640/2757  

data that failed to join: (data/hs_no_geom...csv)  

### Average Speeds Data Dictionary   

tmc|h0|h1|...   
--|-----|-------|---    
tmc code|hour 0 speed|hour 1 speed   

## Background Docs  

Docs: https://gist.github.com/tombuckley/693ba397c4b03564b3689c2219b95e52  

Processing: https://gist.github.com/tombuckley/4e405d87d23eafd51fa48cfb8ebfc3cd  
