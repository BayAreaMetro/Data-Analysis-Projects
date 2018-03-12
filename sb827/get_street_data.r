# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc1___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827
# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc2___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827
# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc3___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827
# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc4___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827
# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc5___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827
# cp /Users/tbuck/Box/DataViz\ Projects/Data\ Services/2016_12/zippedArchives/usauc6___________nw.* /Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827

library(sf)
library(dplyr)

setwd("/Users/tbuck/Documents/Projects/mtc/Data-And-Visualization-Projects/sb827")
sb827_febr_boundaries <- st_read("sb827_feb_amendment_boundaries.geojson")
#4 and 2 seem mostly outside region
nw_sf <- st_read("usauc3___________nw.shp")

nw_sf <- st_transform(nw_sf, crs=26910)
sb827_febr_boundaries <- st_transform(sb827_febr_boundaries, crs=26910)

(mat = st_intersects(nw_sf, sb827_febr_boundaries, sparse = FALSE))
v1 <- apply(mat, 1, any)

nw_sf_s <- nw_sf[v1,]

nw_sf_s <- nw_sf_s[nw_sf_s$LANES>0,c('NAME','LANES')]

lane_width_range <- c(8.2,10.7)

nw_sf_s$width_min_guess <- lane_width_range[[1]]*as.integer(nw_sf_s$NAME)
nw_sf_s$width_max_guess <- lane_width_range[[2]]*as.integer(nw_sf_s$NAME)

st_write(nw_sf_s,"nw_in_boundaries_more_than_0_lane.geojson")

df = data.frame(matrix(rnorm(20), nrow=10))

nw_sf_more_than_2 <- nw_sf_s[nw_sf_s$LANES>2,]

nw_sf_more_than_2_random <- nw_sf_more_than_2[sample(nrow(nw_sf_more_than_2), 200), ]

mapview(nw_sf_more_than_2_random)

nw_sf_827 <- st_read("nw_in_boundaries_more_than_0_lane.gpkg")
st_crs(nw_sf_827) = 26910

nw_sf_827 <- st_transform(nw_sf_827, crs=4326)

st_write(nw_sf_827, "nw_in_boundaries.geojson")

nw2 <- group_by(nw_sf_827,LANES) %>% 
  summarise(geog = st_union(geom))

nw2 <- st_transform(nw_sf_827, crs=4326)
st_write(nw2,"road_network_in_827_boundaries.geojson")

nw.g <- nw_sf_827 %>% group_by(LANES)

df3 <- nw.g %>% summarise(geog = st_union(geom))

library(mapview)
mapview(df3)

st_write(df3,"road_network_in_827_boundaries.shp")