<!-- MarkdownTOC bracket="round" autolink="true" -->

- [Goal](#goal)
- [Method](#method)
- [Outcome](#outcome)
	- [Data](#data)
	- [Summaries](#summaries)

<!-- /MarkdownTOC -->


# Goal 

Output tables of routes and stops for all operators from MTC511 GTFS Data. 

# Data Source

Mostly:
- MTC511 [GTFS data by operator](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/511_orgs.csv).

Also:
- MTC Open Data
- direct from operators (via transit land)

# Method

[Script](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/transit/all_operators.r) - to produce stops and routes from GTFS data. 

# Outcome

## Data

- [(Draft) All Stops and Routes (Shapefile, GeoJSON)-2018](https://mtcdrive.box.com/v/june-2018-draft-1-transit-feat). 
- [(Draft) Bus Routes (Shapefile, GeoJSON)-2014](https://mtcdrive.box.com/s/d160lpolkbna0778kp938vt50jvkztj3)

- [(Draft) AGOL - Routes 2018](https://mtc.maps.arcgis.com/home/item.html?id=aa61ac53d4364a59af74e72369fbfe82)
- [(Draft) AGOL - Stops 2018](https://mtc.maps.arcgis.com/home/item.html?id=47f3befcc83e41008db55cbed81843ac)
- [(Draft) AGOL - Routes 2014](https://mtc.maps.arcgis.com/home/item.html?id=7b60806da9f747de9c6c0d34ff65ae01)

## Summaries
- [summary_routes_14_18.csv](summary_routes_14_18.csv)
