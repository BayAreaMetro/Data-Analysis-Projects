# Goal

Store snippets of code that can be copied and pasted into R Studio to output data related the the US Census. 

# Requirements

- [R Studio](https://www.rstudio.com/) or [MTC DV's R Studio Server](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/tree/master/rstudio-server)
- [Tidycensus](https://walkerke.github.io/tidycensus/) or [censusapi](https://github.com/hrecht/censusapi) packages

# Scripts

- examples/censusapi_package_example.R - get data on race and ethnicity for the Bay Area (censusapi example)
- examples/get_minority.R - get data on race and ethnicity for the Bay Area (tidycensus example)
- 2018_predominance_map/make_predominance_table.Rmd - create (geospatial) tables on the predominant ethnic or racial group in a given census geography (e.g. tract) in the Bay area. 
- [ethnic_groups_tip.Rmd](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/census/2018_tip_equity_analysis/ethnic_groups_tip.Rmd) - assign boolean values to census tracts indicating whether a particular racial or ethnic group is higher than the regional average within them. 

# Data Sources

US Census and TIGER

# Outcomes 

## Race and Ethnicity

### Predominance

- [Excel File for Mapping](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/census/2018_predominance_map/predominance_with_mapping_labels.xlsx?raw=true)
- [CSV](https://mtcdrive.box.com/s/vq3ey8igk9fbj26260i0kd3i48m81mmr)
- [GeoPackage](https://mtcdrive.box.com/s/x63rdqhsmcudy45j6dsu4pw72o9a6kfj)
- [GeoJSON](https://mtcdrive.box.com/s/tbns234lshw4op0ositn4yrstfiuppj4)

### TIP Equity Analysis

- [above_average_ethnic_and_racial_groups_by_tract.xlsx](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/census/2018_tip_equity_analysis/above_average_ethnic_and_racial_groups_by_tract.xlsx)
