#environmental requirements:
#anaconda python: https://www.continuum.io/downloads
#python 3.5 environment: conda create --name py35 python=3.5; source activate py35
#geopandas, simpledbf: conda install -c conda-forge geopandas simpledbf

import geopandas as gpd
import pandas as pd
from simpledbf import Dbf5

###
#read in congested segments spreadsheet
###
#download data: https://mtcdrive.box.com/s/0fdhlrqeqrnebvawsgx83y86920b9bre
cs = pd.read_excel("2016_CS_List_06_13_2017.xlsx")

###
#read tomtom tmc lookup table
###
#download data: https://mtcdrive.box.com/s/rqod8oybpqpnx6ym0osi2h0hoo4znbmb
dbf = Dbf5('usauc3___________rd.dbf', codec='utf-8')
tt_rd = dbf.to_dataframe()

#map column to inrix TMCs
from cs_hs_functions import to_inrix
tt_rd["tmc"] = to_inrix(tt_rd.RDSTMC)

tt_rd.to_csv("usauc3_rd_inrix_tmc.csv")

cs.tmc = cs["TMC ID"]
#filter data to just those that we have congestion data for
tt_rd = tt_rd[tt_rd.tmc.isin(cs.tmc)]

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

nw = nw.dissolve(by="tmc")

########
#join the hourly speeds table to  
#the tomtom geoms 
########

nw.reset_index(inplace=True)
cs_g = cs.merge(nw, on='tmc',how="left", suffixes=("_cs","_nw"))

#separate out empty geometry tmc's
cs_g[cs_g.geometry.isnull()].to_csv('cs_no_geom_for_tmc.csv')
cs_g = cs_g[~cs_g.geometry.isnull()]
cs_g = gpd.GeoDataFrame(cs_g)

###
#output to shapefile and csv
###
#we output to shapefile because the source data
#is in shapefile format
#and has a mix of multilinestring and linestring
#that is specific to the shapefile format

cs_g_shp = cs_g.loc[:,["tmc","geometry"]]
cs_g_shp.to_file('cs.shp', layer='cs')

#output the attribute table to csv
#the shapefile dbf form has requirements
#for types that aren't within 
#overcoming for this project
#so the user will be expected to join the csv to the shapefile
cs_gd_csv = pd.DataFrame(cs_g.loc[:,['joinindex','tmc_c','Route #', 'DIR', 'Segment #', 'County',
       'LOCATION', 'startTime', 'endTime', 'length (Miles)',
       'Segment Delay  (Veh-Hrs)', 'Segment Delay  (Veh-Hrs)2', 'Rank',
       'Source', 'VPHPL', 'Include in Default?', 'ID', 'NAME',
       'SHIELDNUM', 'ID']])

cs_gd_csv.to_csv('cs_data.csv')