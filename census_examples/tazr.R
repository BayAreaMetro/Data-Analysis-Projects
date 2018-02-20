# ## Goal
#
# Our goal will be to reproduce an equivalence table relating year 2000 Bay Area Census Tracts to MTC's 
#Transportation Analysis Zones (TAZ).
#
# The long-term goal is to be able to reproduce this lookup table for any census geographies. 
# It may also be useful to reproduce the table for other kinds of geographies (e.g. jurisdictions).
#
#
# ### Lookup Table
#
# Lets inspect the lookup table that we want to reproduce.

library(readr)
Tract_zone_2000 <- read_csv("https://s3-us-west-2.amazonaws.com/equivalence/Tract_zone_2000.csv")

print(head(Tract_zone_2000))
#   output:
#   | Tract| rtaz1| rtaz2| rtaz3| rtaz4| rtaz5|
#   |-----:|-----:|-----:|-----:|-----:|-----:|
#   | 10100|    41|    NA|    NA|    NA|    NA|
#   | 10200|    40|    NA|    NA|    NA|    NA|
#   | 10300|    39|    NA|    NA|    NA|    NA|
#   | 10400|    38|    NA|    NA|    NA|    NA|
#   | 10500|    22|    23|    NA|    NA|    NA|
#   | 10600|    37|    NA|    NA|    NA|    NA|

# So, we'll need to look up the ID for all TAZs that relate to a Census Tract, by ID.

#
# TAZ Data
# ----------
# We download and read TAZ Data from MTC's open data portal.
library(sf)

taz1454 <- st_read("https://opendata.arcgis.com/datasets/b85ba4d43f9843128d3542260d9a2f1f_0.geojson")

knitr::kable(table(st_is_valid(taz)))
# |Var1  | Freq|
# |:-----|----:|
# |FALSE |    1|
# |TRUE  | 1453|
###
# one of the TAZ geometries is "invalid".
# this is probably not important but could be, so lets look into it

plot(taz[!st_is_valid(taz),], max.plot=1)

# geom looks OK visually
# lets make note of the taz_id to review later

invalid_taz_id <- taz1454[!st_is_valid(taz1454),]$TAZ1454

# note: this is not a data type issue per se (geojson, M drive, etc)
# i also checked the source shapefile on M and it has the same
# invalid geometry (plus another additional one)
# arcmap does not see any of these geometries as invalid

#
# Census Data
# ----------
# We download and read Census Data from the US Census.
# we use the tigris package but you have lots of options for this
# again, its important that you know that the geometries are valid
# so we'll check this.

library(tigris)
counties=c("01","13","41","55","75","81","85","95","97")
tracts <- tigris::tracts("CA", counties, class="sf", year=2000)
tracts <- dplyr::select(tracts,TRACTCE00)
tracts <- dplyr::rename(tracts,tract = TRACTCE00)
tracts <- sf::st_transform(tracts, crs=26910)
detach("package:tigris", unload=TRUE)

knitr::kable(table(st_is_valid(tracts)))

#
#
# Script
#
#
## ------------------------------------------------------------------------

#clean up the headers and data
## ------------------------------------------------------------------------
taz1454 <- dplyr::select(taz1454,TAZ1454)
taz1454 <- dplyr::rename(taz1454, taz = TAZ1454)
print(head(taz1454))

taz1454 <- sf::st_transform(taz1454, crs=26910)

## ------------------------------------------------------------------------
tt <- sf::st_join(tracts,taz1454)
tt <- as.data.frame(tt)
tt <- dplyr::select(tt,-geometry)
print(head(tt))

#check the problem geom
knitr::kable(tt[tt$taz==invalid_taz_id,])

#still intersects so seems fine
#   |        |tract  | TAZ1454|
#   |:-------|:------|-------:|
#   |3844.4  |346102 |    1102|
#   |3845.7  |346101 |    1102|
#   |3847.1  |355305 |    1102|
#   |3848.4  |355304 |    1102|
#   |3849.7  |355303 |    1102|
#   |3850.5  |355302 |    1102|
#   |3851.6  |355301 |    1102|
#   |3863.6  |346201 |    1102|
#   |3874.7  |338302 |    1102|
#   |3974.9  |355106 |    1102|
#   |4005.13 |355104 |    1102|

#-----------------------
###Output desired table format
#
#Ok so its now time to format the tt table
#in the sparse matrix style format from the 2000 data

tt$num <- ave(tt[['taz']], 
              tt[['tract']], 
              FUN = seq_along)

tt$header_string <- 'rtaz'

et <- tt %>% 
  tidyr::unite("header_string", 
                   header_string, 
                   num) %>% 
    tidyr::spread(header_string, taz)

#inspect the results:
knitr::kable(head(et[,c(1:10)]))

# looks like there are more taz intersections in this data set than the lookup from the year 2000
# the year 2000 data had maximum 6 taz intersections per tract.
# this has many more (more than 10)
#
#   |tract  | rtaz_1| rtaz_10| rtaz_11| rtaz_12| rtaz_13| rtaz_14| rtaz_15| rtaz_16| rtaz_17|
#   |:------|------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
#   |010100 |     41|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
#   |010200 |     40|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
#   |010300 |     40|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
#   |010400 |     39|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
#   |010500 |     41|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|
#   |010600 |     38|      NA|      NA|      NA|      NA|      NA|      NA|      NA|      NA|

# lets have a look at the first tract to see why that might be the case
## ------------------------------------------------------------------------
## the year 2000 original data expects only 1 taz for this tract
#   | Tract| rtaz1| rtaz2| rtaz3| rtaz4| rtaz5|
#   |-----:|-----:|-----:|-----:|-----:|-----:|
#   | 10100|    41|    NA|    NA|    NA|    NA|

# plot(tracts[tracts$tract=="010100",], col="red", max.plot=1)
# 
# tazs <- taz1454[taz1454$tract=="010100",]$taz
# plot(taz1454[taz1454$taz %in% tazs,], col = sf.colors(categorical = TRUE, alpha = .5))

##when we plot it, its clear that the taz extends slightly into nearby tracts
