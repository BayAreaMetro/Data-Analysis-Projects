*Draft*

<!-- MarkdownTOC bracket="round" autolink="true" -->

- [Goal](#goal)
	- [Things to consider](#things-to-consider)
	- [Project Management](#project-management)
- [Data Sources](#data-sources)
	- [TomTom](#tomtom)
	- [Census \(TIGER\).](#census-tiger)
	- [Travel Model](#travel-model)
- [Geometric Equivalence](#geometric-equivalence)
- [Topologically Integrated Products](#topologically-integrated-products)
- [Equivalence Without Topological Integration](#equivalence-without-topological-integration)
	- [Census & TomTom](#census--tomtom)
	- [Census & Travel Model](#census--travel-model)
- [Across Regional Data Products](#across-regional-data-products)
- [Temporal Consistency](#temporal-consistency)
	- [Within Major Data Products](#within-major-data-products)

<!-- /MarkdownTOC -->


# Goal

Develop equivalencies between geographies for PDAs, the travel model, and census. 

## Things to consider

1. How to address when geographies for one dataset don't fully conform and/or nest with the paired geography.

2. How to address water geographies for census (tracts, block groups, etc.).

3. How to support regular updates to this process as Travel Model 2 comes on board and census geographies are updated in 2020.

## Project Management 

- [Related Asana Task](https://app.asana.com/0/23428721243788/384604299561177) 


# Data Sources



## TomTom

The 2016-12 TomTom data [here](https://github.com/BayAreaMetro/DataServices/tree/master/TomTom%20Base%20Map). 

We use the "other areas" tables for Census geometries. 

## Census (TIGER). 

We draw TIGER data directly from the US Census FTP

We use [an R Package to make this easier](https://github.com/walkerke/tigris). 

There are numerous other options for retrieving Census geometries (see [census_data_tools.md](census_data_tools.md)) 

## Travel Model

[Transportation Analysis Zones](http://opendata.mtc.ca.gov/datasets/transportation-analysis-zones) - These are known at MTC as the '1454' zones, for the number of rows in the table. 

These are identical (excepting coordinate system) to the data found on the "M Drive", which is where the canonical data is hosted. Normally we would point to data in the same coordinate system, but, in this case, the coordinate system difference is irrelevant because the geometries are roughly drawn in any case.  

# Geometric Equivalence

Below we summarize the geometric relationships among and across geometry products. 

In summary, data are typically [topologically integrated](https://www.e-education.psu.edu/natureofgeoinfo/book/export/html/1612) by product, and then nearly consistent across products, because they are based on the US Census Topologically Integrated Geographic Encoding and Referencing (TIGER) data.  

For each relationship across products, we outline some rough estimates and advice to users wanting to make comparisons across these products. Each section has links to further detail. 

# Topologically Integrated Products

The following list of data products are each internally consistent (share edges/topology/geometries).

This means they are topologically integrated. 

For example, Census blocks and tracts shared edges and nodes within any given major census. 

- Tom Tom (needs to be verified in what domains)
- Census (Block, Block Groups, Tracts)
- Travel Model (in theory)

# Equivalence Without Topological Integration 

Below we document relationships across the products above. 

Some use cases for these relationships are: 

- Comparing outputs from the Travel Model to Census demographics
- Creating Cartographic visualizations from Census demographics

## Census & TomTom

### Attributes/Dimensions

TomTom's "other areas" Census tracts and blocks are from the 2010 Census. 

The Blocks data from TomTom have about ~2000 fewer blocks than the Census 2010 blocks because TomTom Blocks do not contain blocks that area on places like roadways and medians.   

### Geometries

Census TIGER and TomTom geometries are *slightly* different for each feature

In practice, this means that calculations of things like population density (denominator of area) will yield slightly different results across these two data sets, with the same (non-geometric) attribute information. 

However, the share of the differences in their area is normally distributed.  

Therefore, they are interchangeable for the vast majority of analytical tasks for cross-sectional analysis. 

However, it is up to the user to clearly specify an appropriate level of geographic precision for their analysis. Please see the document below for more detail:

Detail [here](https://bayareametro.github.io/Data-And-Visualization-Projects/equivalencies/tomtom_census.html). 

## Census & Travel Model

### Travel Model 1

Given the non-trivial geometric relationship between these units, the user will have to decide what kind of equivalence is useful for their modeling purposes. 

MTC has defined, for Year 2000 and 2010 Census Tracts, the following formal spatial relationships to Travel Model 1 Geometries (TAZ):

- (a) smaller than the TAZ, 
- (b) roughly the same as the TAZ, and
- (c) larger than the TAZ. 

See [here](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/tree/master/equivalencies/taz_tract) for more detail. 

### Travel Model 2

Travel Model 2 Geographies are based on axioms that will allow for easy comparison with Census geometries. Review for D&V work forthcoming. 

# Across Regional Data Products

MTC, ABAG, and other (e.g. Air District) are produce areas based on transit, land use, and other features. Below we outline what some of these features are and how they relate to one another.  

Priority:

- [Transit Service Defined Areas](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/legislative_transit_data.md)
- Priority Development Areas

Layers to consider (time allowing):

- Farmland
- Habitats

# Temporal Consistency 

## Within Major Data Products

Users hoping to compare demographic data across time and spatial features are urged to consider the advice of domain experts in doing so. 

### Bay Area Census Blocks 2000 & 2010 

We need to look into this more, but by design TIGER should be backwards topologically consistent, with some changes to reflect changes in features in the world. 

We briefly summarize the consistency of TIGER line geometries from 2000 and 2010 [here](https://bayareametro.github.io/Data-And-Visualization-Projects/equivalencies/compare_blocks_2000_2010.html)







