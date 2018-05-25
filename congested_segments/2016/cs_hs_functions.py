import fiona
import geopandas as gpd

def sheets_to_df(xls):
	#returns a dataframe indexed by tmc_id
	index_column = xls.parse(0).loc[:,'Hour of Measurement Tstamp']
	df1 = pd.DataFrame(index=index_column)
	for sheet_name in xls.sheet_names:
		df2 = xls.parse(sheet_name)
		df2.set_index('Hour of Measurement Tstamp',drop=True,inplace=True)
		df1 = df1.join(df2)
	df1.reset_index(inplace=True)
	df1 = df1.T
	df1 = df1.drop(['Hour of Measurement Tstamp'])
	df1.index.name = 'tmc'
	return df1 

def filter_by_tmcid(rec,selection_array=[]):
	return rec["properties"]["ID"] in (selection_array)

def read_network(tmc_array,shapefile_path="usauc3___________nw.shp"):
	#download network data: https://mtcdrive.box.com/s/rqod8oybpqpnx6ym0osi2h0hoo4znbmb
	c = fiona.open(shapefile_path)
	hits = filter(lambda x:filter_by_tmcid(x,selection_array=tmc_array), c)
	gdf1 = gpd.GeoDataFrame.from_features(hits)
	return gdf1

#given a pandas series of tomtom TMC codes, 
#map them to INRIX Codes and return the new pandas series
def to_inrix(tomtom_tmcs):
	inrix_tmcs = tomtom_tmcs.str.slice(start=1)
	return inrix_tmcs