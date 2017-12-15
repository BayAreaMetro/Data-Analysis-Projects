## What

This is a guide to setting up a local parcel database. 

## Requirements

This guide is based around MacOS Sierra

It assumes you have [Docker](https://www.docker.com/) installed and that you are willing to work at a *nix command line. 

## 1) Set Up PostGIS in a docker container

Examples below, please adapt for your desired username, password, etc. 

```
docker pull mdillon/postgis
docker run --name postgis1 -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 mdillon/postgis

#get the container id
docker ps

docker exec -it container_id bash

--then, in container bash:
psql -U postgres
CREATE USER tom;
ALTER USER "tom" WITH PASSWORD '******';
ALTER USER tom WITH SUPERUSER;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
GRANT ALL PRIVILEGES ON database analysis_scratch TO tom;

--tune the db with https://www.pgconfig.org/

\q
```

## 2) Load Parcel Data

You can download the parcel SQL dump here: 

https://mtcdrive.box.com/s/ekw8bl41o3j8bggmyoec0sqlhibbq6ap

And you can load it into your docker container like so:

```
psql -h localhost -p 5432 -U tom -W --dbname=analysis_scratch /postgis_parcels/setup_parcel_schema.sql
psql -h localhost -p 5432 -U tom -W --dbname=analysis_scratch < parcel.sql
psql -h localhost -p 5432 -U tom -W --dbname=analysis_scratch /postgis_parcels/add_spatial_index.sql
```
