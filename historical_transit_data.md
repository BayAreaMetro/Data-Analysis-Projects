## Historical Transit Processing 

[Problem Statement](#problem-statement)   
[Data Sources](#data-sources)   
[Methodology](#methodology)   
[Outcome](#outcome)   

### Problem Statement  

Review the past RTD datasets collected since 2006 to determine the possibility of creating GTFS data by year for all transit operators in the nine county bay region.

### Data Sources

Collected by staff at MTC and from GTFS Data Exchange. Listed in `data/cached_gtfs.csv`

### Methodology

Process each GTFS file listed in `data/cached_gtfs.csv` for routes, stops, and frequencies.  

We use existing GTFS libraries, primarily [gtfs-lib](https://github.com/afimb/gtfslib-python) and [gtfsr](https://github.com/ropensci/gtfsr), to load, validate, transform (to spatial standard formats), and calculate frequencies. Processing steps are logged in `data/cached_gtfs.csv`.


#### Routes

see [`/R/historical_routes/output_historical_routes_by_region.R`](https://github.com/BayAreaMetro/RegionalTransitDatabase/blob/afad7ec4096aad89d1d69aa9b22ae3cb7486fdf7/R/historical_routes/output_historical_routes_by_region.R)

#### Stops and Frequencies

see [`/rtd/process_cached_gtfs_for_points_and_frequencies.py`](https://github.com/BayAreaMetro/RegionalTransitDatabase/blob/f9359cd88d8879bb6fe348f20fed0db5a5d372e3/rtd/process_cached_gtfs_for_points_and_frequencies.py)
