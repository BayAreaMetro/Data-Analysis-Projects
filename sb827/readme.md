# 827 Analysis (Draft)

This is a summary of some analysis tasks. Some of these will be addressed here others will not based on tasking. 

## Streets

What *streets* within a transit rich zone (1/2 mile from a major transit stop and within ¼ mile of a high-quality transit corridor (AKA TPA eligible areas <http://mtc.maps.arcgis.com/home/webmap/viewer.html?useExisting=1&layers=165d990e3d1341c4942b79e526eafe0f>) would be subject to maximum heights at 85 feet, 55 feet and 45 feet?

## Zoning

Overlay that with the existing height maximums. 

## City Summary

What difference, if any, would a given city see with the SB 827 provisions in place?

## FAR, Height and Parking

SB 827 would also exempt housing projects in transit rich zones from maximum density and floor area ratios, as well as parking minimums. prioritize the height analysis, then parking would be second priority.

## Transit Stops and Associated Areas

### relevant amendment details :
please see [here](https://medium.com/@Scott_Wiener/sb-827-amendments-strengthening-demolition-displacement-protections-4ced4c942ac9)

### data
- bus_stops_on_high_frequency_corridors.geojson - stops for the high frequency routes from plan bay area from [here](https://hub.arcgis.com/datasets/6b9d4597489d451187f49525f1a7b6cf)
- major_stops_existing.geojson - major stops from plan bay area from [here](http://opendata.mtc.ca.gov/datasets/major-transit-stops-2017)
- sb827_feb_amendment_boundaries.geojson - combined boundary of the above based on february amendment

### scripts
- get_data_827_feb_2018_amendments.r
- make_boundary.r

### draft data processing example

example [here](https://bayareametro.github.io/Data-And-Visualization-Projects/sb827/sb827_amendment_example.html)

