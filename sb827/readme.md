<!-- MarkdownTOC autolink="true" bracket="round" -->

- [827 Analysis \(Draft\)](#827-analysis-draft)
- [february amendment :](#february-amendment-)
- [Streets](#streets)
	- [Street Widths as Derived from Street Data](#street-widths-as-derived-from-street-data)
- [Transit Stops and Associated Areas](#transit-stops-and-associated-areas)
	- [data](#data)
	- [scripts](#scripts)
	- [transit data how-to](#transit-data-how-to)

<!-- /MarkdownTOC -->

# 827 Analysis (Draft)

[The proposed bill](https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=201720180SB827).

# february amendment :
please see [here](https://medium.com/@Scott_Wiener/sb-827-amendments-strengthening-demolition-displacement-protections-4ced4c942ac9)

# Streets

What *streets* within a transit rich zone (1/2 mile from a major transit stop and within ¼ mile of a high-quality transit corridor (AKA TPA eligible areas <http://mtc.maps.arcgis.com/home/webmap/viewer.html?useExisting=1&layers=165d990e3d1341c4942b79e526eafe0f>) would be subject to maximum heights at 85 feet, 55 feet and 45 feet?

## Street Widths as Derived from Street Data

Data are available [here](http://mtc.maps.arcgis.com/home/item.html?id=74876cd626354abe90f49d66f447e530&jobid=6cb68df9-4498-413c-84e9-82bb31d58d1d), output by [get_street_data.r](get_street_data.r). 

# Transit Stops and Associated Areas

## data

- bus_stops_on_high_frequency_corridors.geojson - stops for the high frequency routes from plan bay area from [here](https://hub.arcgis.com/datasets/6b9d4597489d451187f49525f1a7b6cf)
- major_stops_existing.geojson - major stops from plan bay area from [here](http://opendata.mtc.ca.gov/datasets/major-transit-stops-2017)
- sb827_feb_amendment_boundaries.geojson - combined boundary of the above based on february amendment

## scripts

- get_data_827_feb_2018_amendments.r
- make_boundary.r

## transit data how-to

example [here](https://bayareametro.github.io/Data-And-Visualization-Projects/sb827/sb827_amendment_example.html)

