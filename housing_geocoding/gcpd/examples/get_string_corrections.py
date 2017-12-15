import os
import pickle
import json
import pandas as pd
os.chdir('/Users/tommtc/Documents/Projects/Data-And-Visualization-Projects/housing_geocoding')

from gcpd.gcpd import get_credentials, create_engine, query_db, geocode_gmaps

#def main():
credentials = get_credentials("housing_credentials.json")

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


# if __name__ == "__main__":
# 	main()


