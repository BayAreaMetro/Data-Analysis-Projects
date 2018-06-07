import datetime, urllib.request, urllib.parse, urllib.error
import json
import logging
import os
import datetime
import feedparser
import pandas as pd
from geomet import wkt
import pandas_redshift as pr

WAZE_URL = "https://na-georss.waze.com/rtserver/web/TGeoRSS?tk=ccp_partner&" + \
            "ccp_partner_name=MTCCalifornia&format=XML" + \
            "&types=traffic%2calerts%2cirregularities" +  \
            "&acotu=true" + \
            "&polygon=-123.513794%2c38.753226%3b-121.788940%2c38.633178%3b" +  \
            "-120.552979%2c36.755610%3b-121.865845%2c36.861164%3b" +  \
            "-123.261108%2c37.155063%3b-123.354492%2c37.735100%3b" + \
            "-123.513794%2c38.753226%3b-123.513794%2c38.753226"

def handler(event,context):
    logging.warning('entered the function')
    df1 = get_feed(WAZE_URL)
    df1, data_types = setup_the_table(df1)
    write_to_db(df1,data_types)

def setup_the_table(df1):
    df1.columns = df1.columns.str.replace('linqmap_', '')
    df1['wkt'] = df1['where'].apply(lambda x: wkt.dumps(x, decimals=7))
    df1 = df1.drop(['where', 'title_detail','published_parsed'], axis=1)
    df1['dateAdded']=datetime.datetime.utcnow()
    json1_file = open('data_types_redshift.json')
    json1_str = json1_file.read()
    dt = json.loads(json1_str)
    columns1 = list(dt.keys())
    types1 = list(dt.values())
    df2 = df1[columns1]
    return(df2,types1)

def write_to_db(df1,data_types):
    import datetime
    server = (os.getenv('PG_SERVER'))
    user = (os.getenv('PG_USER'))
    password = (os.getenv('PG_PASSWORD'))
    database = (os.getenv('PG_DATABASE'))
    port = (os.getenv('PG_PORT'))
    db_tablename= (os.getenv('PG_DB_TABLENAME'))
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
    db_tablename= (os.getenv('PG_DB_TABLENAME'))
    pr.connect_to_redshift(dbname = database,
                    host = server,
                    port = port,
                    user = user,
                    password = password)
    pr.connect_to_s3(aws_access_key_id = os.getenv('aws_access_key_id'),
                    aws_secret_access_key = os.getenv('aws_secret_access_key'),
                    bucket = "redshift-etl-temp",
                    append = True)
    # Write the DataFrame to S3 and then to redshift
    pr.pandas_to_redshift(data_frame = df1,
                          redshift_table_name = db_tablename,
                          column_data_types = dtype_list)
    pr.close_up_shop()

def get_feed(url):
    feed = feedparser.parse(url)
    df1 = pd.DataFrame.from_dict(feed['entries'])
    return(df1)

# if __name__ == "__main__":
    # logging.warning('entered the function')
    # df1 = get_feed(WAZE_URL)
    # df1, data_types = setup_the_table(df1)
    # write_to_db(df1,data_types)

