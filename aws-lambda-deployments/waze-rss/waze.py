import datetime, urllib.request, urllib.parse, urllib.error
import json
import logging
import os
import datetime
import feedparser
import pandas as pd
from geomet import wkt
import pandas_redshift as pr
from time import mktime
from datetime import datetime

WAZE_URL = (os.getenv('waze_url'))

def handler(event,context):
    logging.warning('getting the feed')
    df1 = get_feed(WAZE_URL)
    logging.warning('formatting the table')
    df2 = setup_the_table(df1)
    logging.warning('partitioning the feed')
    alerts_df,alerts_types = get_alerts(df2)
    jams_df,jams_types = get_jams(df2)
    logging.warning('writing alerts to db')
    write_to_db(alerts_df,alerts_types,db_tablename='waze.alerts_2018')
    logging.warning('writing jams to db')
    write_to_db(jams_df,jams_types,db_tablename='waze.jams_2018')

def rename_columns(df1):
    df1.columns = df1.columns.str.replace('linqmap_', '')
    return(df1)

def geojson_to_wkt(df1):
    df1['wkt'] = df1['where'].apply(lambda x: wkt.dumps(x, decimals=7))
    return(df1)

def add_timestamp(df1):
    df1['dateAdded']=datetime.utcnow()
    return(df1)

def setup_the_table(df1):
    df1 = rename_columns(df1)
    df1 = geojson_to_wkt(df1)
    df1 = add_timestamp(df1)
    return(df1)

def get_alerts(df1):
    df1 = df1.loc[df1.title=='alert',:]
    df1['x'] = df1['where'][0]['coordinates'][0]
    df1['y'] = df1['where'][0]['coordinates'][1]
    json1_file = open('alerts_data_types.json')
    json1_str = json1_file.read()
    dt = json.loads(json1_str)
    columns1 = list(dt.keys())
    alerts_types = list(dt.values())
    alerts_df = df1[columns1]
    return(alerts_df,alerts_types)

def get_jams(df1):
    df1 = df1.loc[df1.title=='jam',:]
    json1_file = open('jams_data_types.json')
    json1_str = json1_file.read()
    dt = json.loads(json1_str)
    columns1 = list(dt.keys())
    jams_types = list(dt.values())
    jams_df = df1[columns1]
    return(jams_df,jams_types)

def write_to_db(df1,data_types,db_tablename):
    import datetime
    logging.basicConfig() 
    try:
        logging.warning('writing the feed to the db')
        push_to_rs(df1,data_types,db_tablename)
    except Exception as e:
        logging.warning("db write error")
        logging.warning(e)

def push_to_rs(df1,dtype_list,db_tablename):
    server = (os.getenv('PG_SERVER'))
    user = (os.getenv('PG_USER'))
    password = (os.getenv('PG_PASSWORD'))
    database = (os.getenv('PG_DATABASE'))
    port = (os.getenv('PG_PORT'))
    pr.connect_to_redshift(dbname = database,
                    host = server,
                    port = port,
                    user = user,
                    password = password)
    pr.connect_to_s3(aws_access_key_id = os.getenv('aws_access_key_id'),
                    aws_secret_access_key = os.getenv('aws_secret_access_key'),
                    bucket = "redshift-etl-temp")
    # Write the DataFrame to S3 and then to redshift
    pr.pandas_to_redshift(data_frame = df1,
                          redshift_table_name = db_tablename,
                          column_data_types = dtype_list,
                          append=True)
    pr.close_up_shop()

def make_milliseconds(array1):
    try:
        dt1 = datetime.fromtimestamp(mktime(array1))
        dt1 = int(round(dt1.timestamp() * 1000))
    except:
        dt1 = 0
    return(dt1)

def get_feed(url):
    feed = feedparser.parse(url)
    #dump json to file
    with open('feed_example.json', 'w') as fp:
        json.dump(feed, fp)
    df1 = pd.DataFrame.from_dict(feed['entries'])
    df1['pubmillis'] = df1.published_parsed.apply(make_milliseconds)
    return(df1)

if __name__ == "__main__":
    logging.warning('getting the feed')
    df1 = get_feed(WAZE_URL)
    logging.warning('formatting the table')
    df2 = setup_the_table(df1)
    logging.warning('partitioning the feed')
    alerts_df,alerts_types = get_alerts(df2)
    jams_df,jams_types = get_jams(df2)
    logging.warning('writing alerts to db')
    write_to_db(alerts_df,alerts_types,db_tablename='waze.alerts_2018')
    logging.warning('writing jams to db')
    write_to_db(jams_df,jams_types,db_tablename='waze.jams_2018')

