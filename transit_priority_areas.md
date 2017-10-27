## Transit Priority Area Processing 2017

[Problem Statement](#problem-statement)   
[Data Sources](#data-sources)   
[Methodology](#methodology)   
[Outcome](#outcome)   

### Problem Statement  

Identify bus routes and stops that match the definition of a Transit Priority Area (TPA).  Output geometries for them.  
See Senate Bill 375 for more detailed definition of a TPA [SB 375 Legislation](http://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=200720080SB375).
 
#### Bus Routes
-  [1/4](http://www.leginfo.ca.gov/pub/11-12/bill/asm/ab_0901-0950/ab_904_bill_20120612_amended_sen_v94.html) and/or [1/2](http://leginfo.legislature.ca.gov/faces/billCompareClient.xhtml?bill_id=201320140SB743) mile Buffer around existing or planned *high-frequency* bus routes (lines).

#### Bus Stops
-  0.2 mile Buffer around existing or planned *high-frequency* bus stops.

*See Qualifying Criteria in Methods for a more thorough definition of *high frequency*

#### Rail & Ferry:   
-  Existing rail stations
-  Planned rail stations in an adopted RTP
-  Existing and Planned ferry terminals with bus or rail service   

![stops_and_routes](http://www.fehrandpeers.com/wp-content/uploads/2016/01/SB743-transit-asset_REV-01.png)  

### Data Sources   

#### Bus Stops & Routes
GTFS data (stop time interpolated) from MTC 511 were [processed](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/8a2ce450af213707bbc6d61dbd035363b40f058c/python/preprocess_gtfs_folders.py) and put [here](https://mtcdrive.box.com/s/41tfjd14hazu1x3qe53lt19u7fbiqdjk)      

#### Rail, Ferry & Bus Rapid Transit

A Feature Class from MTCGIS: [TPA Eligible Non Bus Stops](http://mtc.maps.arcgis.com/home/item.html?id=f998f0940316431b99ab5e4ca826133f).

### Methodology   

#### Rail, Ferry & Bus Rapid Transit.  

Columns and values were used to select TPA eligible Rail & Ferry stops from the MTCGIS source data.  See the individual selections in the [Data Subsets](#data-subsets) section under [Outcome](#outcome).   

#### Bus Stop and Route Qualifying Criteria
-  Peak periods were defined as 6 AM to 10 AM and 3 PM to 7 PM (as filtered by [this function](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/9c370d72e9fa0d788fedf33d1cbec5a844e96c19/R/r511.R#L352-L379)) 
-  Bus routes had to meet the criterion for both AM and PM peaks (as checked [here](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/9c370d72e9fa0d788fedf33d1cbec5a844e96c19/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L137-L143)) 
-  Average headway (as calculated [here](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/9c370d72e9fa0d788fedf33d1cbec5a844e96c19/R/r511.R#L144-L159)) during the 4-hour window was used to identify achievement of [15 minute threshold](https://github.com/BayAreaMetro/RegionalTransitDatabase/blob/51aa706e3d422888cf7180c330399d3ab295c55f/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L65-L66)  
-  Bus stops have to be less than 0.2 miles in distance from one another, as calculated [here](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/9c370d72e9fa0d788fedf33d1cbec5a844e96c19/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L198-L200) (i.e., short walk to transfer) 
-  Intersection of at least two existing or planned bus routes with headways of 15 minutes or better during both the morning and evening peak periods 
-  Bus service had to originate from a single route (i.e., not combined headways of multiple routes)  

#### Bus Stops & Routes Step By Step Processing:  
1. Get 2017 Frequency Data
-  download processed (stop time interpolated) data [here](https://mtcdrive.box.com/s/41tfjd14hazu1x3qe53lt19u7fbiqdjk)      
alternatively, process from the source:  
-  [get_and_format_511_gtfs_data](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/master/python/get_and_format_511_for_sql.py)
-  [interpolate blank stop times using gtfs-tools](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/8a2ce450af213707bbc6d61dbd035363b40f058c/python/preprocess_gtfs_folders.py)
2. [Query the Data](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/0435639579044ba099a1f516bb1a896d6bc00ad0/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L54)      
3. [Determine Stop Frequency and Headway](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/0435639579044ba099a1f516bb1a896d6bc00ad0/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L55-L81)  
4. [Combine Into Lines, 1/4, 1/2 mile buffer](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/0435639579044ba099a1f516bb1a896d6bc00ad0/R/priority_routes/identify_bus_tpas_and_output_geometries.R#L156-L191)   

#### Buffers    

These scripts were used to create buffers around some Rail & Ferry features from MTCGIS and the new BRT route (Geneva) from the RTP database:

-  [add_transit and new routes](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/a7cf88601fc73c0eca69aa6b24f2be1a9be3f04a/R/examples/add_transit_stops_new_routes_then_buffer.R)
-  [make polygons from tpa eligible transit stops and routes](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase/blob/a7cf88601fc73c0eca69aa6b24f2be1a9be3f04a/python/make_tpa_polygons.py)

#### Process Buffer Overlays and Summarize Accordingly  
Using the buffers generated in the previous step, dissolve and merge using spatial modeling tools to create a final TPA Polygon Feature Class.  

- Insert Python data processing scripts here.

### Outcome   

#### Transit Priority Areas  

- [Transit Priority Area Buffer Dataset](http://mtc.maps.arcgis.com/home/item.html?id=67cd7a362d364e0190a9566279c61ae4)

#### Data Subsets  

Buffers:  

Category|Planned/Existing|Buffer|Feature Type|Link to Data
-----|------|--------|-----|----
Bus|Existing|1/4 mile|routes|[main_hf_rts_1_4_ml_buf](http://mtc.maps.arcgis.com/home/item.html?id=dc818c03e86243ec8cf85b8995caab4d)
Bus|Existing|1/2 mile|routes|[main_hf_rts_1_2_ml_buf](http://mtc.maps.arcgis.com/home/item.html?id=303f6c62df4842af8459d2cab86b80fe)
Bus|Planned|1/4 mile|routes|[geneva_route_1_4_mile](http://mtc.maps.arcgis.com/home/item.html?id=c076e3dd52b1422bbf2ea122bbd280f3)
Bus|Planned|1/2 mile|route|[geneva_route_1_2_mile](http://www.arcgis.com/home/item.html?id=1e65df8b816c4dd2b41c811dcbdd540c)
Bus|Existing|0.2 mile|stops|[main_hf_stops_with_hf_neighbors_buffer](http://mtc.maps.arcgis.com/home/tem.html?id=a239938913e24c618bea07b6f5f34d52)
Rail&Ferry|Planned|1/2 mile|stops|[heavy rail_and_ferry_1_2_mile_buffer](http://mtc.maps.arcgis.com/home/item.html?id=1bbb5e24e8b048f6b291784920eaf61c)

Individual Points: 

[TPA Eligible High Frequency Bus Stops](http://mtc.maps.arcgis.com/home/item.html?id=1937588fdce446559a5a6de9af3f1900)  

[TPA Eligible Non Bus Stops](http://mtc.maps.arcgis.com/home/item.html?id=f998f0940316431b99ab5e4ca826133f):   

Below are relevant subsets from the Non Bus Stops:  

System|Status|Link to Data
------|-------|----
Rail|Existing|[GeoJSON](https://services3.arcgis.com/i2dkYWmb4wHvYPda/arcgis/rest/services/TPA_Non_Bus_Eligible_Stops_2017/FeatureServer/0/query?where=system+%3D+%27Rail%27+AND+status%3D%27Existing%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&quantizationParameters=&sqlFormat=none&f=pgeojson&token=)
Light Rail|Existing|[GeoJSON](https://services3.arcgis.com/i2dkYWmb4wHvYPda/arcgis/rest/services/TPA_Non_Bus_Eligible_Stops_2017/FeatureServer/0/query?where=system+%3D+%27Light+Rail%27+AND+status%3D%27Existing%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&quantizationParameters=&sqlFormat=none&f=pgeojson&token=)
Rail|Planned or Under Construction|[GeoJSON](https://services3.arcgis.com/i2dkYWmb4wHvYPda/arcgis/rest/services/TPA_Non_Bus_Eligible_Stops_2017/FeatureServer/0/query?where=system+%3D+%27Rail%27+AND+%28status%3D%27Planned%27+OR+status%3D%27Under+Construction%27%29&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&quantizationParameters=&sqlFormat=none&f=pgeojson&token=)
Ferry|Planned or Under Construction|[GeoJSON](https://services3.arcgis.com/i2dkYWmb4wHvYPda/arcgis/rest/services/TPA_Non_Bus_Eligible_Stops_2017/FeatureServer/0/query?where=system+%3D+%27Ferry%27+AND+%28status%3D%27Planned%27+OR+status%3D%27Under+Construction%27%29&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&quantizationParameters=&sqlFormat=none&f=pgeojson&token=)
Bus Rapid Transit|Planned or Under Construction|[GeoJSON](https://services3.arcgis.com/i2dkYWmb4wHvYPda/arcgis/rest/services/TPA_Non_Bus_Eligible_Stops_2017/FeatureServer/0/query?where=system+%3D+%27Bus+Rapid+Transit%27+AND+%28status%3D%27Planned%27+OR+status%3D%27Under+Construction%27%29&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&quantizationParameters=&sqlFormat=none&f=pgeojson&token=)


#### Related Projects:

[TPP & CEQA Density/Intensity Overlay](https://github.com/MetropolitanTransportationCommission/tpp_ceqa_map_for_pba_17)     
