# sudo su
# curl https://packages.microsoft.com/config/rhel/6/prod.repo > /etc/yum.repos.d/mssql-release.repo
# exit
# sudo yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
# sudo ACCEPT_EULA=Y yum install msodbcsql-13.0.1.0-1 mssql-tools-14.0.2.0-1
# above from https://stackoverflow.com/questions/44141081/how-to-install-microsoft-drivers-for-php-for-sql-server-on-amazon-linux-ami#44686812
# # optional: for bcp and sqlcmd
# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
# source ~/.bashrc
# # optional: for unixODBC development headers
# sudo yum install unixODBC-devel

#set up the environment: conda create -n pyodbc python=3.5 pyodbc sqlalchemy pandas
#source activate pyodb
#pip install geocoder
import pandas as pd
from sqlalchemy import create_engine
import numpy as np
import pandas as pd
import itertools as it
import geocoder
import json
import sqlalchemy
import sys
import time
# import click

GEOCODE_CACHE_TABLE = 'gmaps_raw'

# @click.command()
# @click.option('--geocoder', default='google', help='which geocoder to use e.g. google')

#in place of writing try/except for each function below
#to handle errors this class is used as a "decorator"
class handle_exception(object):
	def __init__(self, func):
		self.func = func
	def __get__(self, obj, type=None):
		return self.__class__(self.func.__get__(obj, type))
	def __call__(self, *args, **kwargs):
		try:
			retval = self.func(*args, **kwargs)
		except Exception as e :
			print(e)
			retval = None
		return retval

@handle_exception
def get_credentials(credentials_file):
	with open(credentials_file) as f:
		credentials = json.load(f)
	return(credentials)

@handle_exception
def get_location_type(geocoder_response):
	'''
	returns the location type of a geocode from gmaps
	e.g. values: rooftop, interpolated
	'''
	response_json = geocoder_response.response.json()
	return(response_json['results'][0]['geometry']['location_type'])

@handle_exception
def check_partial_address(geocoder_response):
	'''returns whether there is a flag the address is a partial match'''
	response_json = geocoder_response.response.json()
	if 'partial_match' in response_json['results'][0].keys():
		return True
	else:
		return False

@handle_exception
def geocode_google(address1, maps_api_key):
	return(geocoder.google(address1, key=maps_api_key))

@handle_exception
def geocode_mapzen(address1, maps_api_key):
	'''mapzen expects max 6 requests per second'''
	time.sleep(.17)
	return(geocoder.mapzen(address1, key=maps_api_key))

@handle_exception
def get_latitude(geocoder_response):
	return(geocoder_response.latlng[0])

@handle_exception
def get_longitude(geocoder_response):
	return(geocoder_response.latlng[1])

@handle_exception
def cache_json_response(geocoder_response):
	response_json = geocoder_response.response.json()
	return(response_json)

@handle_exception
def print_url_for_gmaps_error(geocoder_response):
	p_url = geocoder_response.url
	print(p_url)

@handle_exception
def get_partial_addr(connection_engine):
		#pull records to geocode (those not already done) from the permit table
	select_statement = "select " \
						"p.joinid, p.apn, p.county, p.jurisdictn, p.address, p.zip " + \
						"from import.Permits_10_18_2017 p " + \
						"WHERE p.joinid not in " + \
						"(select joinid from geocode_results.gmaps g1 " + \
						"WHERE partial_addr" + \
						";"
	permits_df = pd.read_sql(select_statement, con=connection_engine)
	permits_df = permits_df[~permits_df.address.isnull()]
	return(permits_df)

@handle_exception
def get_uncoded_gmaps_records(connection_engine):
		#pull records to geocode (those not already done) from the permit table
	select_statement = "select " \
						"p.joinid, p.apn, p.county, p.jurisdictn, p.address, p.zip " + \
						"from import.Permits_10_18_2017 p " + \
						"WHERE p.joinid not in " + \
						"(select joinid from geocode_results.gmaps g1 " + \
						"UNION select joinid from geocode_results.gmaps_2016) " + \
						"AND permyear>2015;"
	permits_df = pd.read_sql(select_statement, con=connection_engine)
	permits_df = permits_df[~permits_df.address.isnull()]
	return(permits_df)

@handle_exception
def get_uncoded_mapzen_records(connection_engine):
		#pull records to geocode (those not already done) from the permit table
	select_statement = "select " \
						"p.joinid, p.apn, p.county, p.jurisdictn, p.address " + \
						"from import.Permits_10_18_2017 p " + \
						"WHERE p.joinid not in (select joinid from geocode_results.mapzen);"
	permits_df = pd.read_sql(select_statement, con=connection_engine)
	permits_df = permits_df[~permits_df.address.isnull()]
	return(permits_df)

@handle_exception
def get_all_records(connection_engine):
		#pull records to geocode (those not already done) from the permit table
	select_statement = "select " \
						"p.joinid, p.apn, p.county, p.jurisdictn, p.address " + \
						"from import.Permits_10_18_2017 p " + \
						";"
	permits_df = pd.read_sql(select_statement, con=connection_engine)
	permits_df = permits_df[~permits_df.address.isnull()]
	return(permits_df)

@handle_exception
def gmaps_geocode_df(permits_df,
	connection_engine,
	apikey,
	rate_limit=10,
	GEOCODE_CACHE_TABLE=GEOCODE_CACHE_TABLE):
	'''	
	call to geocoder and then cache the 
	results in a table in case of parsing failure
	todo: the handling of indexes should be simplified
	'''

	addresses_s = permits_df.full_address
	addresses_s = addresses_s[0:rate_limit]
	gmaps_response_s = addresses_s.apply(geocode_google, maps_api_key=apikey)
	df_cache = pd.DataFrame({'response':gmaps_response_s.apply(cache_json_response), 
					'joinid':permits_df.joinid[addresses_s.index]})

	df_cache.to_sql(name=GEOCODE_CACHE_TABLE,
					schema="geocode_results",
					dtype={'joinid':sqlalchemy.types.NVARCHAR,
			   			   'response':sqlalchemy.types.PickleType},
					con=connection_engine,
					if_exists = 'append',
					index=df_cache.joinid)
	return(gmaps_response_s)

@handle_exception
def parse_gmaps_response(gmaps_response_s, permits_df):
	'''
	parse the gmaps response
	we do this because we need things like
	the location type/quality of the geocoded response
	'''
	gmaps_response_s = gmaps_response_s[gmaps_response_s!=None]
	latitude_s = gmaps_response_s.apply(get_latitude) 
	longitude_s = gmaps_response_s.apply(get_longitude) 

	partial_response_s = gmaps_response_s.apply(check_partial_address)
	type_response_s = gmaps_response_s.apply(get_location_type)

	#get just the joinids for which there is a gmaps response
	joinid_s = permits_df.joinid[gmaps_response_s.index]
	#build the table of latitude and longitude 
	#to put back in the db
	gmaps_response_df = pd.DataFrame({'joinid':joinid_s, 
						'latitude':latitude_s, 
						'longitude':longitude_s, 
						'location_type':type_response_s, 
						'partial_addr':partial_response_s}, index=gmaps_response_s.index)
	return(gmaps_response_df)

@handle_exception
def geocode_mapzen_df(permits_df, apikey, rate_limit=25000):
	#now do it with mapzen (25k limit)
	addresses_s = permits_df.loc[0:rate_limit, 'address']

	mapzen_response_s = addresses_s.apply(geocode_mapzen, 
							  maps_api_key=apikey)

	mapzen_response_s = mapzen_response_s[mapzen_response_s!=None]

	latitude_s = mapzen_response_s.apply(get_latitude) 
	longitude_s = mapzen_response_s.apply(get_longitude) 
	joinid_s = permits_df.joinid[mapzen_response_s.index]

	mapzen_response_df = pd.DataFrame({'joinid':joinid_s, 
						'latitude':latitude_s, 
						'longitude':longitude_s}, 
						index=mapzen_response_s.index)
	return(mapzen_response_df)

def main():
	credentials = get_credentials("housing_credentials.json")

	#connect to the database
	#on windows 10, need to create a 64 bit 
	#ODBC connection on the OS (here named 'housing')
	#unclear how to do this on the Amazon variant of the redhat linux distro
	#that we use for lambda--some notes above
	conn_string = "mssql+pyodbc://{}:{}@MYMSSQL".format(
		credentials['SQL_USER'], 
		credentials['SQL_PWD'])
	engine = create_engine(conn_string)
	engine.execute("USE {}".format(credentials['DATABASE']))

	permits_df = get_all_records(engine)

	a_s = permits_df.address

	needs_review = a_s.apply(ends_with_ca)
 	
 	#these dont end with CA
	a_s[needs_review]


def ends_with_ca(address):
	return(address[-2:] == "CA")


	# permits_df = get_uncoded_gmaps_records(engine)

	# addresses_s = permits_df.address
	# zip_s = permits_df.zip
	# jurisdctn_s = permits_df.jurisdictn
	# zip_s = zip_s.replace('NULL','')

    permits_df['full_address'] = addresses_s + ", " + jurisdctn_s + ", CA " + zip_s

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
	
if __name__ == "__main__":
	main()


