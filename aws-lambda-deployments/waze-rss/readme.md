<!-- MarkdownTOC bracket="round" autolink="true" -->

- [Waze Logs by Date](#waze-logs-by-date)
	- [2017-01-24 to 2018-05-23](#2017-01-24-to-2018-05-23)
		- [tablenames](#tablenames)
		- [fields](#fields)
	- [2018-05-23 to 2018-06-11](#2018-05-23-to-2018-06-11)
		- [tablenames:](#tablenames-1)
		- [script](#script)
		- [fields](#fields-1)
	- [2018-06-06 to 2018-20-08](#2018-06-06-to-2018-20-08)
		- [tablenames:](#tablenames-2)
		- [script](#script-1)
		- [fields](#fields-2)
		- [notes](#notes)
	- [2018-20-08 to present](#2018-20-08-to-present)
		- [tablenames:](#tablenames-3)
		- [script](#script-2)
		- [fields](#fields-3)

<!-- /MarkdownTOC -->

# Waze Logs by Date

Document past and present logging of Waze data

## 2017-01-24 to 2018-05-23

### tablenames 

- traffic.waze_rss_v1 

### fields

[headers_v1.md](headers_v1.md)

## 2018-05-23 to 2018-06-11

### tablenames: 
- traffic.waze_rss_v1_5_alerts  
- traffic.waze_rss_v1_5_jams 

### script

[legacy_logger_mssql.js](legacy_logger_mssql.js)

### fields

[alerts](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/75e6eef7127001d74470fdc232524a8535751a32/aws-lambda-deployments/waze-rss/field_types.md#alerts)

[jams](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/75e6eef7127001d74470fdc232524a8535751a32/aws-lambda-deployments/waze-rss/field_types.md#jams)

## 2018-06-06 to 2018-20-08

### tablenames: 
- traffic.waze_rss_v2 
- traffic.waze_rss_v2_1 

### script

[waze.py at commit 3cb74](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/3cb74ce590a6e55b9ba0b5f51be8e22f29f5277d/aws-lambda-deployments/waze-rss/waze.py)

### fields

[data_types_redshift.json at commit 3cb74](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/3cb74ce590a6e55b9ba0b5f51be8e22f29f5277d/aws-lambda-deployments/waze-rss/data_types_redshift.json)

### notes

`waze_rss_v2_1` added `title` variable (e.g. 'jam'). this information can also be derived from other fields (e.g. `reportating` == NULL for jams). 

## 2018-20-08 to present

### tablenames: 
- waze.alerts_2018 
- waze.jams_2018 

### script

[waze.py at commit 75e6eef7127001d74470fdc232524a8535751a32](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/75e6eef7127001d74470fdc232524a8535751a32/aws-lambda-deployments/waze-rss/waze.py)

### fields

[alerts](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/75e6eef7127001d74470fdc232524a8535751a32/aws-lambda-deployments/waze-rss/alerts_data_types.json)

[jams](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/75e6eef7127001d74470fdc232524a8535751a32/aws-lambda-deployments/waze-rss/jams_data_types.json)
