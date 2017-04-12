#environmental requirements:
#anaconda python: https://www.continuum.io/downloads
#python 3.5 environment: conda create --name py35 python=3.5; source activate py35
#geopandas, simpledbf: conda install -c conda-forge geopandas simpledbf

import geopandas as gpd
import pandas as pd
from simpledbf import Dbf5
import fiona

###
#read in hourly speeds spreadsheet
###
#download data: https://mtcdrive.box.com/s/xpq139i2j28la01w2o2u06c3p3dnx748
xls = pd.read_excel("2016_Hourly_Speeds.xlsx", sheetname=None)

from cs_hs_functions import sheets_to_df
hs = sheets_to_df(xls)

###
#read tomtom tmc lookup table
###
#download data: https://mtcdrive.box.com/s/rqod8oybpqpnx6ym0osi2h0hoo4znbmb
dbf = Dbf5('usauc3___________rd.dbf', codec='utf-8')
tt_rd = dbf.to_dataframe()

#map column to inrix TMCs
from cs_hs_functions import to_inrix
tt_rd["tmc"] = to_inrix(tt_rd.RDSTMC)

#filter data to just those that we have speeds for
tt_rd = tt_rd[tt_rd.tmc.isin(hs.tmc)]

########
#read the tomtom network
#filter it by hourly speed ID's
########

from cs_hs_functions import filter_by_tmcid, read_network

hourly_ids = tt_rd.ID.unique()
nw = read_network(hourly_ids, shapefile_path="usauc3___________nw.shp")
nw = nw.merge(tt_rd, on="ID", how="left", suffixes=("_nw","_rd"))

# ########
# #Dissolve that table by TMC ID
# ########

nw = nw.dissolve(by="tmc_rd")

########
#join the hourly speeds table to  
#the tomtom geoms 
########

hs_g = hs.merge(nw,on='tmc',how="left", suffixes=("_hs","_nw"))

#separate out empty geometry tmc's
hs_g[hs_g.geometry.isnull()].to_csv('hs_no_geom_for_tmc.csv')
hs_g = hs_g[~hs_g.geometry.isnull()]
hs_g = gpd.GeoDataFrame(hs_g)

###
#output to shapefile and csv
###
#we output to shapefile because the source data
#is in shapefile format
#and has a mix of multilinestring and linestring
#that is specific to the shapefile format

hs_g_shp = hs_g.loc[:,["tmc","geometry"]]
hs_g_shp.to_file('hs.shp', layer='hs')
hs_g_csv = hs_g.iloc[:,0:26]
hs_g_csv.drop('geometry',axis=1,inplace=True)
hs_g_csv.to_csv('hs_attributes.csv')
