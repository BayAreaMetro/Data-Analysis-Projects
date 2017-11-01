### Category

[General](#general)  
[Transportation](#transportation)   
[Policy](#Policy)  
[Demographic](#demographic)  

#### General

#### Transportation:

##### Transit 

[Regional Transit Database](https://github.com/MetropolitanTransportationCommission/RegionalTransitDatabase)   
Source: Transit Operators (via MTC 511)    
Input: [Google Transit Feed Specification](https://developers.google.com/transit/gtfs/) Text Files    
Output: Multiple, Bus Frequency by Geometry    
Dependencies: ~SQL Server~, Python, R, GDAL

##### Sub-Projects  
- [State of California Code Transit Service Definition Data](legislative_transit_data.md)

- [Routes, Stops, and Frequencies by Transit Provider from 2008 to 2017](historical_transit_data.md) 

##### Vehicles

[Traffic](https://github.com/MetropolitanTransportationCommission/vital-signs-traffic-data)     
Source: INRIX, TomTom     
Input: Excel Spreadsheets of Traffic Data, Road Geometries     
Output: Traffic by Geometry      
Dependencies: Python, Pandas  

###### Two Bridge Users Study
[Scripts](https://github.com/BayAreaMetro/bridge-transactions/tree/master/Two-Bridge-Users)    
[Readme](https://mtcdrive.app.box.com/notes/226792245627)  
Source: MTC FasTrak data  
Input: Bridge Transactions  
Output: An estimate of users crossing 2 or more distinct bridges per day  
Dependencies: R   

#### Policy:  

[Housing Permit Geocoding (2017)](https://github.com/BayAreaMetro/Data-And-Visualization-Projects/blob/master/housing_geocoding.md)  
Source: Various   
Input: Housing Permits   
Output: Geocoded Housing Permits   
Dependencies: Windows 10, SQL Server Spatial, Python, Pandas

[Zoning & General Plans(GP)](https://github.com/MetropolitanTransportationCommission/zoning)   
Source: Jurisdictions   
Input: Zoning/GP, Parcel Geometry   
Output: Zoning by Parcel Geometry   
Dependencies: *nix, PostGIS, GDAL, Make

[Parcels (2010)](https://github.com/MetropolitanTransportationCommission/bayarea_urbansim/blob/c3b249c54e8bae14737c6840dc8ff70a858a887f/data_regeneration/Makefile)   
Source: County Governments   
Input: 9 Tables of Parcel Geometries by County   
Output: 1 Table of Parcel Geometries by Region   
Dependencies: *nix, PostGIS, GDAL, *nix, Make

[Affordable Housing Locations (2016)](https://github.com/MetropolitanTransportationCommission/housing/tree/master/ahs)   
Input: Multiple Spreadsheets  
Output: Records Deduplicated and Located by Address  
Dependencies: Python, Pandas  

[Residential Real Estate Prices](https://github.com/MetropolitanTransportationCommission/motm/tree/master/2017_04#redfinplaces)    
Source: Redfin    
Input: Census Places Geometries (TomTom), CSV Export of [Tableau Data file](https://www.redfin.com/blog/data-center)    
Output: Residential Sale Prices by Place Geometry      
Dependencies: Python, Pandas
