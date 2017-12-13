import os
import pickle
import json
import pandas as pd
os.chdir('/Users/tommtc/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding')

from gcpd.gcpd import get_credentials, create_engine, query_db, geocode_gmaps

#def main():
credentials = get_credentials("housing_credentials.json")

	#connect to the database
	#on windows 10, need to create a 64 bit 
	#ODBC connection on the OS (here named 'MSSQL')
	#unclear how to do this on the Amazon variant of the redhat linux distro
	#that we use for lambda--some notes above

conn_string = "mssql+pyodbc://{}:{}@MYMSSQL".format(
	credentials['SQL_USER'], 
	credentials['SQL_PWD'])
engine = create_engine(conn_string)
engine.execute("USE {}".format(credentials['DATABASE']))

select_gmaps_raw = "select " \
					"joinid, response " + \
					"from geocode_results.gmaps_raw p " + \
					";"
df_gm = query_db(engine, select_gmaps_raw)

df_gm['response_json'] = df_gm['response'].apply(lambda x: json.dumps(pickle.loads(x)))

df1 = pd.read_json(df_gm['response_json'])

j1 = df_gm.loc[1,'response_json'] 
from pandas.io.json import json_normalize
j2 = json_loads(j1)
j3 = j2['results']
df2 = json_normalize(j3)

#s1 = geocode_gmaps(df1, apikey=credentials['gmaps_api_key'])

#addresses_s = permits_df.address
#zip_s = permits_df.zip
#jurisdctn_s = permits_df.jurisdictn
#zip_s = zip_s.replace('NULL','')

# permits_df['full_address'] = addresses_s + ", " + jurisdctn_s + ", CA " + zip_s

# gmaps_response_s = gmaps_geocode_df(permits_df, 
# 	engine, 
# 	credentials['gmaps_api_key'],
# 	rate_limit=2300)
# gmaps_response_df = parse_gmaps_response(gmaps_response_s, permits_df)

# gmaps_response_df.to_csv('gmaps_2016b_df_temp.csv')

# gmaps_response_df.to_sql(name='gmaps_2016', 
# 		   schema="geocode_results", 
# 		   con=engine, 
#   			   dtype={'joinid':sqlalchemy.types.NVARCHAR, 
# 					'latitude':sqlalchemy.types.FLOAT, 
# 					'longitude':sqlalchemy.types.FLOAT, 
# 					'location_type':sqlalchemy.types.NVARCHAR, 
# 					'partial_address':sqlalchemy.types.BOOLEAN},
# 		   if_exists = 'append', 
# 		   index=gmaps_response_df.joinid)

# permits_df = get_uncoded_mapzen_records(engine)
# import pdb; pdb.set_trace()
# mapzen_response_df = geocode_mapzen_df(permits_df,
# 	credentials['mapzen_api_key'], 
# 	rate_limit=15000)
# import pdb; pdb.set_trace()
# mapzen_response_df.to_sql(name='mapzen_response', 
# 		   schema="geocode_results", 
# 		   con=engine, 
# 		   if_exists = 'append', 
# 		   index=mapzen_response_df.joinid)


# if __name__ == "__main__":
# 	main()


