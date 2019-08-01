-----------------------
CREATE VIEW all_2010_parcels AS
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
alameda_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
contracosta_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
marin_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
napa_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sanfrancisco_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sanmateo_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
santaclara_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
solano_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sonoma_2010

----------------------
CREATE TABLE all_2010_parcels_apn_indexed AS
select county, apn1, apn2, apn3, apn4, gacres, shape
FROM all_2010_parcels

---------------------------
CREATE INDEX apn1_2010_idx ON all_2010_parcels_apn_indexed (apn1);
CREATE INDEX apn2_2010_idx ON all_2010_parcels_apn_indexed (apn2);
CREATE INDEX apn3_2010_idx ON all_2010_parcels_apn_indexed (apn3);
CREATE INDEX apn4_2010_idx ON all_2010_parcels_apn_indexed (apn4);

-----------------------
CREATE VIEW all_2015_parcels AS
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
alameda_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
contracosta_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
marin_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
napa_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sanfrancisco_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sanmateo_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
santaclara_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
solano_2015
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
sonoma_2015

----------------------
CREATE TABLE all_2015_parcels_apn_indexed AS
select county, apn1, apn2, apn3, apn4, gacres, shape
FROM all_parcels

---------------------------
CREATE INDEX apn1_2015_idx ON all_2015_parcels_apn_indexed (apn1);
CREATE INDEX apn2_2015_idx ON all_2015_parcels_apn_indexed (apn2);
CREATE INDEX apn3_2015_idx ON all_2015_parcels_apn_indexed (apn3);
CREATE INDEX apn4_2015_idx ON all_2015_parcels_apn_indexed (apn4);

CREATE VIEW permits_2010_parcels AS
SELECT
hp.joinid, hp.apn,
p.apn1, p.apn2, p.apn3, p.apn4,
st_astext(st_pointonsurface(st_transform(p.shape, 4326))) as point_on_surface_wkt_4326,
st_astext(st_centroid(st_transform(p.shape, 4326))) as centroid_wkt_4326
FROM (select * from permits2016 hp where apn NOT LIKE 'NULL') hp
LEFT JOIN all_2010_parcels_apn_indexed p
      ON hp.apn = p.apn1
      OR hp.apn = p.apn2
      OR hp.apn = p.apn3
      OR hp.apn = p.apn4
      OR REPLACE(hp.apn, ' ', '') = p.apn1
      OR REPLACE(hp.apn, ' ', '') = p.apn2
      OR REPLACE(hp.apn, ' ', '') = p.apn3
      OR REPLACE(hp.apn, ' ', '') = p.apn4
      OR REPLACE(hp.apn, ' ', '-') = p.apn1
      OR REPLACE(hp.apn, ' ', '-') = p.apn2
      OR REPLACE(hp.apn, ' ', '-') = p.apn3
      OR REPLACE(hp.apn, ' ', '-') = p.apn4
WHERE p.shape is not NULL;

CREATE VIEW permits_2015_parcels AS
SELECT
hp.joinid, hp.apn,
p.apn1, p.apn2, p.apn3, p.apn4,
st_astext(st_pointonsurface(st_transform(p.shape, 4326))) as point_on_surface_wkt_4326,
st_astext(st_centroid(st_transform(p.shape, 4326))) as centroid_wkt_4326
FROM (select * from permits_12_8_2017 hp where apn NOT LIKE 'NULL') hp
LEFT JOIN all_2015_parcels_apn_indexed p
      ON hp.apn = p.apn1
      OR hp.apn = p.apn2
      OR hp.apn = p.apn3
      OR hp.apn = p.apn4
      OR REPLACE(hp.apn, ' ', '') = p.apn1
      OR REPLACE(hp.apn, ' ', '') = p.apn2
      OR REPLACE(hp.apn, ' ', '') = p.apn3
      OR REPLACE(hp.apn, ' ', '') = p.apn4
      OR REPLACE(hp.apn, ' ', '-') = p.apn1
      OR REPLACE(hp.apn, ' ', '-') = p.apn2
      OR REPLACE(hp.apn, ' ', '-') = p.apn3
      OR REPLACE(hp.apn, ' ', '-') = p.apn4
WHERE p.shape is not NULL;


CREATE VIEW apn_centroids AS
  SELECT
    joinid,
    centroid_wkt_4326
  FROM
    permits_2010_parcels
  WHERE cast(centroid_wkt_4326 AS VARCHAR(256)) NOT LIKE ''
  UNION ALL
  SELECT
    joinid,
    centroid_wkt_4326
  FROM
    permits_2015_parcels
  WHERE centroid_wkt_4326 IS NOT NULL;


create view apn_centroids_deduped AS
WITH dedup AS (
    SELECT p.joinid,
           p.centroid_wkt_4326,
           ROW_NUMBER() OVER(PARTITION BY p.joinid
                                 ORDER BY p.joinid DESC) AS rk
      FROM apn_centroids p)
SELECT d.joinid,
       d.centroid_wkt_4326
  FROM dedup d
 WHERE d.rk = 1;


CREATE VIEW to_geocode AS
SELECT * from permits2016
  WHERE joinid not in (select joinid from apn_centroids_deduped);