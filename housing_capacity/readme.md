# goal

A) Total housing capacity within Transit Priority Areas, using our zoning and parcel databases (calc could be du/ac x parcel area) and subtracting this from current housing units (either using ACS or the parcel database), if possible reported by city, county, and rail transit corridor (i.e. all TPAs around BART stations)

B) Total housing capacity within Priority Development Areas, using same analysis described above, if possible reported by PDA, City and County.

# data sources

[land use model run 7224](https://mtcdrive.box.com/s/aw1r2dposx2g3wl3adr7pc46xb3hg372)

[parcel data-mtc staff only](https://mtcdrive.app.box.com/s/s5a7zmy03fdeixuvh6vgxgqg4ukxontr)

US Census ACS

# methods

1) [housing_capacity.R](housing_capacity.R) - join parcel data to model run outputs and group by geographies as assigned in parcel data. 

2) [qa_with_census.R](qa_with_census.R) - QA 'total_residential_units' against ACS/Census and sum to block groups. 

# outcome

requested attributes are delivered at several geographies and summary levels:

1) [block group geometries](https://mtcdrive.box.com/s/06xndbj4o49ca6aqifzm28czt42lo4j8) - this ended up being the right level of geographic abstraction, both for the user and for QA
2) [simplified, projected parcels](https://mtcdrive.box.com/s/pm4butqccxs9g4j034ci7a8mmlq9ethi) - make it easier to user to summarise by arbitrary geographies
3) [(draft) summary tables](https://mtcdrive.box.com/shared/static/9od4m6yfeb8nniatf7rl1fpb2vpnv2hy.zip) - these were a first pass--it turned out that the user found geographically referenced data more useful. 
 