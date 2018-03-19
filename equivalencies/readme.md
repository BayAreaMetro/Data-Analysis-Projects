*Draft*

# Equivalencies

## Goal

Develop equivalencies between geographies for PDAs, the travel model, and census. 

### Project Management 

- [Asana](https://app.asana.com/0/23428721243788/384604299561177) 

## Data

### Sources

#### TomTom

The 2016/12 TomTom data [here](https://github.com/BayAreaMetro/DataServices/tree/master/TomTom%20Base%20Map)). 

#### [Census (TIGER)](https://github.com/walkerke/tigris)

We draw TIGER data directly from the US Census website using [this R Package](https://github.com/walkerke/tigris). 

There are numerous other options for retrieving Census geometries. 

#### Travel Model

[Transportation Analysis Zones](http://opendata.mtc.ca.gov/datasets/transportation-analysis-zones) - These are known at MTC as the '1454' zones, for the number of rows in the table. 

These are identical (excepting coordinate system) to the data found on the "M Drive", which is where the canonical data is hosted. Normally we would point to data in the same coordinate system, but, in this case, the coordinate system difference is irrelevant because the geometries are roughly drawn in any case.  

## Methods

### Internally Consistent

The following list of data products are each internally consistent (share edges/topology/geometries). They are not consistent across products. 

- Tom Tom
- Census
- Travel Model (in theory)

### Nearly Consistent

Below we document relationships across the products above. 

#### Census & TomTom

#### Census & Travel Model

### Non-Consistent

Priority:

- [Transit Service Defined Areas](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/legislative_transit_data.md)
- Priority Development Areas

Layers to consider (time allowing):

- Farmland
- Habitats

## Outcome