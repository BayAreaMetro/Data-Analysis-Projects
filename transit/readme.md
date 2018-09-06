<!-- MarkdownTOC bracket="round" autolink="true" -->

- [Goal](#goal)
- [Data Source](#data-source)
- [Method](#method)
	- [scripts](#scripts)
	- [script dependencies/tools](#script-dependenciestools)
		- [gtfsr](#gtfsr)
		- [tidytransit](#tidytransit)
		- [r511](#r511)
- [Outcome](#outcome)
	- [Summaries](#summaries)
	- [Data](#data)
- [Background / Futher work](#background--futher-work)

<!-- /MarkdownTOC -->


# Goal 

Output tables of routes and stops for all operators from MTC511 GTFS Data. 

# Data Source


2014 Regional Transit Database - These data are on an MTC SQL Server database. Contact DV staff for more details. 

Mostly:
- MTC511 [GTFS data by operator](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/511_orgs.csv).

Supplemented with:
- MTC Open Data
- direct from operators (via transit land)

We found, in reviewing data pulled for present day (2018), and comparing it to 2014 data, that it was necessary to supplement MTC511 with several sources in order to get to the same geometries. These are documented in [all_operators.R](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/all_operators.r) script. 

These included: 
- Air Bart (2014)
- Vine (Yountville Trolley), 
- American Canyon (2014) 
- Santa Rosa (CityBus), 
- Amtrak,
- [specific routes on County Connection, Angel Island Ferry, and Fairfield Suisun transit](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/all_operators.r#L122-L128), and 
- [Altamont commuter rail](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/all_operators.r#L122-L128)

# Method

## scripts

[Script](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/all_operators.r) - to produce stops and routes from GTFS data. 

## script dependencies/tools

### gtfsr

In these scripts we used an MTC fork of the [gtfsr package](https://github.com/BayAreaMetro/gtfsr) to read a majority of transit data for this project from MTC 511. This should work fine for these scripts as is. 

### tidytransit

Since writing of these scripts, staff cleaned up the fork of gtfsr and published a package called [tidytransit](http://tidytransit.r-transit.org/). In theory, because it is published to CRAN, it is easier to install and is more maintainable. These scripts might need to be changed somewhat to leverage that package but it should also be much easier to use.   

### r511

There is also a (very minimal) r511 package [published to CRAN](https://cran.r-project.org/web/packages/r511/index.html) for working with requests to the 511 API. Users may find that rolling their own scripts for this is preferable.  

# Outcome

## Summaries

The following CSV summarises, at a high level, the number of routes included in the following data products per transit operator:

- [summary_routes_14_18.csv](summary_routes_14_18.csv)

## Data

- [(Draft) All Stops and Routes (FileGDB, Shapefile, GeoJSON)-2018](https://mtcdrive.box.com/v/june-2018-draft-1-transit-feat). 
- [(Draft) Bus Routes (Shapefile, GeoJSON)-2014](https://mtcdrive.box.com/s/d160lpolkbna0778kp938vt50jvkztj3)
- [(Draft) AGOL - Routes 2014](https://mtc.maps.arcgis.com/home/item.html?id=7b60806da9f747de9c6c0d34ff65ae01)

# Background / Futher work

Ths scripts here are an outcome of the work on the [RegionalTransitDatabase](https://github.com/BayAreaMetro/RegionalTransitDatabase).  

Users that need more specific data or outputs, or want to better understand the history of how we have processed transit data should consult that repository. It could eventually be [merged as a subfolder, with history](https://stackoverflow.com/questions/1683531/how-to-import-existing-git-repository-into-another) here or in DataServices. The history may be relevant if users want to switch back to the legacy SQL scripts, for example. Or, you may find the [list of historical GTFS transit](https://github.com/BayAreaMetro/RegionalTransitDatabase/blob/master/data/cached_gtfs.csv) data useful.
