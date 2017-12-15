from gcpd.gcpd import get_credentials, create_engine,query_db, geocode_gmaps, parse_json1, parse_json2, normalize_address_components, normalize_gmaps_response

def main():
	credentials = get_credentials("housing_credentials.json")

	conn_string = "mssql+pyodbc://{}:{}@MYMSSQL".format(
		credentials['SQL_USER'], 
		credentials['SQL_PWD'])
	engine = create_engine(conn_string)
	engine.execute("USE {}".format(credentials['DATABASE']))

	permits_df = get_partial_addr(engine)

	s1 = gmaps_geocode_df_simpler(permits_df, apikey=credentials['gmaps_api_key'])

    os.chdir('/Users/tommtc/Documents/Projects/Data-And-Visualization-Projects')

	addresses_s = permits_df.address
	zip_s = permits_df.zip
	jurisdctn_s = permits_df.jurisdictn
	zip_s = zip_s.replace('NULL','')

	#######
	#review attribute domains
	######

 	#these dont end with CA
	a_s[needs_review]

	# permits_df = get_uncoded_gmaps_records(engine)

	# addresses_s = permits_df.address
	# zip_s = permits_df.zip
	# jurisdctn_s = permits_df.jurisdictn
	# zip_s = zip_s.replace('NULL','')

	permits_df['full_address'] = addresses_s + ", " + jurisdctn_s + ", CA " + zip_s



	gmaps_response_s = gmaps_geocode_df(permits_df, 
		engine, 
		credentials['gmaps_api_key'],
		rate_limit=2300)
	gmaps_response_df = parse_gmaps_response(gmaps_response_s, permits_df)

	gmaps_response_df.to_csv('gmaps_2016b_df_temp.csv')

	gmaps_response_df.to_sql(name='gmaps_2016', 
			   schema="geocode_results", 
			   con=engine, 
   			   dtype={'joinid':sqlalchemy.types.NVARCHAR, 
						'latitude':sqlalchemy.types.FLOAT, 
						'longitude':sqlalchemy.types.FLOAT, 
						'location_type':sqlalchemy.types.NVARCHAR, 
						'partial_address':sqlalchemy.types.BOOLEAN},
			   if_exists = 'append', 
			   index=gmaps_response_df.joinid)

	permits_df = get_uncoded_mapzen_records(engine)
	mapzen_response_df = geocode_mapzen_df(permits_df,
		credentials['mapzen_api_key'], 
		rate_limit=15000)
	mapzen_response_df.to_sql(name='mapzen_response', 
			   schema="geocode_results", 
			   con=engine, 
			   if_exists = 'append', 
			   index=mapzen_response_df.joinid)

if __name__ == "__main__":
	print("please rewrite this script depending on your database/table data model")
	#main()


