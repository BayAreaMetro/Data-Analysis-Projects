## Housing Data Collection and Analysis

[Problem Statement](#problem-statement)   
[Data Sources](#data-sources)   
[Methodology](#methodology)   
[Outcome](#outcome)   

### Problem Statement  

How much residential housing is being created on an annual basis in the Bay Area? How much of that housing is affordable? Are jurisdictions meeting their targets for the [Regional Housing Needs Allocation (RHNA)?](https://abag.ca.gov/our-work/housing/rhna-regional-housing-need-allocation). In order to answer these questions on a regular basis, ABAG has previously undertaken the collection of residential building permits from local jursidictions, geocoded them in order to provide spatial/location context, and analyzed the data to determing which permits fall within [Priority Development Areas (PDAs)](https://mtc.ca.gov/our-work/plans-projects/focused-growth-livable-communities/priority-development-areas), [Transit Priority Areas (TPAs)](http://opendata.mtc.ca.gov/datasets/d97b4f72543a40b2b85d59ac085e01a0_0) and [Housing Element Sites](http://www.hcd.ca.gov/community-development/housing-element/index.shtml). Data collected directly from jurisdictions by ABAG covered the years 2014-2017. 


As of 2018, [HCD](http://www.hcd.ca.gov/) has provided a platform for collecting state-wide [Annual Progress Reports (APR)](http://www.hcd.ca.gov/community-development/housing-element/docs/Housing-Element-Annual-Progress-Report-Instructions-2018.pdf). This resulted in ABAG no longer having to collect data individually from local jurisdictions in the Bay Area, but instead waiting for HCD to complete it's data collection process, and then requesting the 2018 data from HCD. Since the data collected by HCD serves to address the requirement that local jurisdictions report their housing progress to the State annually, the 2018 data contains not just building permit data, but applications, entitlements, certificates of occupancy, preserved units and demolition data as well.

A more detailed overview of this project from inception and moving forward can be found [HERE](https://mtcdrive.box.com/s/spw9bfsf12fsqi98u4226ju343q3xyq2)

### Data Sources

#### 2018 collection
- [Source Data received from HCD](https://mtcdrive.box.com/s/ttcb4omh8cu5xueq7xe7n5dfrvhngyqy)
- [Report Mockup received from HCD upon request for a Data Dictionary](https://mtcdrive.box.com/s/gf8t1eg8lxqa3p32hts29u5ngshffs67)

Reference:
- [Housing Element APR Instructions](https://mtcdrive.box.com/s/ttva7pv05yia3jd12zy412dhcisolull)
- [Housing Element APR Form 2018](https://mtcdrive.box.com/s/s356mc2eerrwsyhtxwyx9o783wt45b99)


#### 2016 Collection

Metadata details are in the permitDataDictionary table on the web application database.   

- [Source Data by County](https://mtcdrive.box.com/s/8u764glqse2ktnwxkqse9n6cw6tp3hcl)  

#### 2015 Collection

- [Location Data](http://opendata.mtc.ca.gov/datasets/residential-building-permits-features)  
- [Attribute Data](http://opendata.mtc.ca.gov/datasets/residential-building-permits-attributes)  

#### Location Data Sources

- Assessor's Parcels 2010, 2015, 2018
- Assessors websites  

#### Administrative Data Sources   

- [Transit Priority Areas](http://opendata.mtc.ca.gov/datasets/transit-priority-areas-2017)
- [Priority Development Areas](http://opendata.mtc.ca.gov/datasets/priority-development-areas-current) 
- [Housing Element Sites 2015-2023](http://opendata.mtc.ca.gov/datasets/regional-housing-need-assessment-2015-2023-housing-element-sites) 
- [Housing Element Sites 2007-2014](http://opendata.mtc.ca.gov/datasets/regional-housing-need-assessment-2007-2014-housing-element-sites) 

### Methodology (Updated 2018)

The data were received from HCD as a single spreadsheet. In order to be able to track housing progress from the application stage through to the issuance of certificates of occupancy, a process that can span more than a single year, the original dataset was separated out into core tables as follows:

- [Housing Applications](https://data.bayareametro.gov/Development/Housing-Applications/qsgp-tugj)
- [Housing Entitlements](https://data.bayareametro.gov/Development/Housing-Entitlements/5a22-yhk2)
- [Housing Building Permits](https://data.bayareametro.gov/Development/Housing-Permits/fyfd-5etv)
- [Housing Certificates of Occupancy](https://data.bayareametro.gov/Development/Housing-Certificates/r63z-g785)

Unique identifiers were created for these tables to provide a means of cross-referencing records. In order to incorporate [data collected previously by ABAG](http://opendata.mtc.ca.gov/datasets/residential-building-permits-attributes) into the new table structure created by HCD, a data crosswalk was created.
- [Data Crosswalk ABAG to HCD Building Permits](https://mtcdrive.box.com/s/ig7x1jbxk4316zkm27xlqa9bwtyl2eq0)

The data were then cleaned and checked for duplicates. Duplicate APNs or addresses were flagged for review and then removed if necessary. In the case of building permits, duplicates were reviewed from both the 2018 dataset and previous years to make sure jurisdictions did not report the same building permit multiple times in different years.

Finally, certificates of occupancy reported in 2018 were related to building permits from previous years where applicable. 



#### Data Cleaning (2018)  

  

#### Duplicates (2018)


#### Relating Certificates to Building Permits


#### Spatial Analysis (2018)

- Update the location for all entitlement addresses using Google Maps or assessor parcel information. 
- Update WKT field in entitlements table
- Conduct spatial analysis and update flags for PDA, TPA, Housing Element Site

#### Assessor Website search  

To locate permitted projects not located through afforementioned geocoding processes, we relied on Assessor websites or Planning and Development Department websites to obtain information. All county sites offered interactive parcel lookup tools which provided the spatial information necessary to manually geocode remaining permitted projects using our in-house mapping tool called [Project Mapper](http://project-mapper.us-west-2.elasticbeanstalk.com/). The interactive parcel lookup tools are listed below by county. 

- [Alameda County Parcel Lookup](http://gis.acgov.org/Html5Viewer/index.html?viewer=parcel_viewer)
- [Contra Costa County Parcel Lookup](https://ccmap.cccounty.us/Html5/index.html?viewer=CCMAP)
- [Marin County Parcel Lookup](https://www.marinmap.org/Html5Viewer/Index.html?viewer=smmdataviewer) 
- [Napa County Parcel Lookup](http://gis.napa.ca.gov/Html5Viewer/Index.html?viewer=Public_HTML)
- [San Francisco County Parcel Lookup](http://propertymap.sfplanning.org/)
- [San Mateo County Parcel Lookup](http://maps.smcgov.org/GE_4_4_0_Html5Viewer_2_5_0_public/?viewer=raster)
- [Santa Clara County Parcel Lookup](http://www.sccpropertyinfo.org/)
- [Sonoma County Parcel Lookup](http://imsportal.sonoma-county.org/ActiveMap/)



### Outcome

