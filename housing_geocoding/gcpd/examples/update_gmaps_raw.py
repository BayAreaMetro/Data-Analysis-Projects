import os
import pickle
import json
import pandas as pd
os.chdir('/Users/tommtc/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding')

from gcpd.gcpd import get_credentials, create_engine,query_db, geocode_gmaps, parse_json1, parse_json2, normalize_address_components, normalize_gmaps_response

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
					"joinid, response, response_json " + \
					"from geocode_results.gmaps_raw p " + \
					";"
df_gm = query_db(engine, select_gmaps_raw)

#df_gm['response_json'] = df_gm['response'].apply(lambda x: json.dumps(pickle.loads(x)))

df_gm['formatted_address'] = df_gm['response_json'].apply(parse_json2)

df_gm_sbst = df_gm[~(df_gm['formatted_address'] =="No Results")]

d1 = df_gm_sbst.to_dict(orient='records')

df3 = pd.DataFrame()

for item in d1:
	df_out = normalize_gmaps_response(item)
	df3 = pd.concat([df_out, df3])

df_gm_sbst.to_csv('gmaps_flattenedfirst_result_address.csv')

df_gm_sbst.to_sql(name='gmaps_formatted_address',schema="geocode_results",con=engine,if_exists = 'append',index=df_gm_sbst.joinid)


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


