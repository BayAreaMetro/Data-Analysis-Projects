---this is a cut paste of all the views on the location schema

CREATE VIEW location.hand_review_11_27_2017
  AS 
    SELECT joinid, action, note
  FROM import.geocoding_hand_review_11_27_2017
UNION ALL
    SELECT joinid, action, note
  FROM import.manual_review_tb
go

CREATE VIEW location.apn_centroids AS
  SELECT
    joinid,
    centroid_wkt_4326
  FROM
    import.outside_bay_with_apn_lookup_2015_parcels
  WHERE cast(centroid_wkt_4326 AS VARCHAR(256)) NOT LIKE ''
  UNION ALL
  SELECT
    hpjoinid,
    centroid_wkt_4326
  FROM
    import.apn_lookup_2015_parcels1
  WHERE centroid_wkt_4326 IS NOT NULL
go

create view location.apn_centroids_deduped AS
WITH dedup AS (
    SELECT p.joinid,
           p.centroid_wkt_4326,
           ROW_NUMBER() OVER(PARTITION BY p.joinid
                                 ORDER BY p.joinid DESC) AS rk
      FROM location.apn_centroids p)
SELECT d.joinid,
       d.centroid_wkt_4326
  FROM dedup d
 WHERE d.rk = 1
go

CREATE VIEW location.manual_latlongs AS
select
  joinid, manual_lat as lat, manual_lon as lon
from
  import.try_geocode_fix_manual_11_29_2017
WHERE manual_lat IS NOT NULL
UNION ALL
  SELECT
   joinid, manual_lat2 as lat, manual_lon2 as lon
from
   import.outside_bay_area_fixes
WHERE manual_lat2 IS NOT NULL
go

create view location.manual_latlongs_deduped AS
WITH dedup AS (
    SELECT cast(p.joinid as varchar(256)) as joinid,
           p.lat,
           p.lon,
           ROW_NUMBER() OVER(PARTITION BY cast(p.joinid as varchar(256))
                                 ORDER BY cast(p.joinid as varchar(256)) DESC) AS rk
      FROM location.manual_latlongs p)
SELECT d.joinid,
       d.lat,
       d.lon
  FROM dedup d
 WHERE d.rk = 1
go

CREATE VIEW location.geocoded AS
SELECT p.joinid, p.permyear, p.projname, p.address,
  m.latitude as lat_mz,
  m.longitude as lon_mz,
  g.latitude as lat_gm,
  g.longitude as lon_gm,
  pf.Lat as lat_pf,
  pf.Long as lon_pf,
  g.location_type as gm_location_type,
  g.partial_addr as gm_partial_addr
FROM import.Permits_10_18_2017 as p
  LEFT JOIN location.permitfeature_deduped pf
  ON p.joinid = pf.joinid
LEFT JOIN geocode_results.mapzen_all_years as m
ON p.joinid = m.joinid
LEFT JOIN geocode_results.gmaps_all_years as g
ON g.joinid = m.joinid
go

CREATE VIEW location.hand_review_11_27_2017_simple_actions AS
    SELECT cast(joinid as varchar(256)) as joinid,
        note,
      (CASE WHEN action IN ('remove from map',
                        'action unclear',
                        'No fix available',
                        'APN located in 2015 parcels',
                        'unclear if address exists',
                        'none',
                        'action',
                        'No fix available',
                        'APN located in 2015 parcels',
                        'Made no modification to original address information and Google found location.',
                        'Google found a location with address, county, and state',
                        'keep but flag',
                        'APN located in 2015 parcels')
            THEN 'try_apn'
    WHEN action IN ('update city',
                    'use apple maps',
                    'use bing',
                    'use new address',
                    'use mapzen',
                    'add zip',
                    'add zip and retry',
                    'bad zip',
                    'Google could not find it, Bing found location, and APN located in 2015 parcels',
                    'Google found a location after adding zip code to address, county, and state',
                    'Google found a location with address, city, and state.',
                    'Google found a location with address, city, and state. Location matched APN selected parcel',
                    'Google found a location with address, county, and state after spelling out Springs',
                    'Made no modification to original address information and Google found location. Location is on a RHNA 5 housing element site.')
            THEN 'try_geocode_fix'
    WHEN action IN ('keep but flag',
                    'keep google',
                    'near pda')
            THEN 'keep_as_is'
      ELSE 'other' END) AS simple_action
    FROM location.hand_review_11_27_2017
go

CREATE VIEW location.geocoded_with_hand_review AS
SELECT m.joinid,
       m.source,
       m.latitude,
       m.longitude,
       r.centroid_wkt_4326,
       ml.lat as manual_lat,
       ml.lon as manual_lon,
       hr.simple_action,
       hr.note
FROM location.geocoded_single_result m
LEFT JOIN location.apn_centroids_deduped r
  ON m.joinid = r.joinid
LEFT JOIN location.manual_latlongs_deduped ml
    ON m.joinid = ml.joinid
LEFT JOIN location.hand_review_11_27_2017_simple_actions_deduped hr
  ON m.joinid = hr.joinid
go

CREATE VIEW location.location_review_process AS
SELECT joinid,
       simple_action,
      (CASE
         WHEN centroid_wkt_4326 IS NOT NULL
          THEN 'apn_centroid'
         WHEN manual_lat IS NOT NULL
          THEN 'manual'
         WHEN simple_action ='keep_as_is'
          THEN source
         WHEN joinid in (select joinid from location.not_in_bay_area_11_29_cache)
           AND centroid_wkt_4326 IS NULL
           AND manual_lat IS NULL
          THEN 'no geocode, no apn, no fix, originally geocoded outside bay area'
         WHEN simple_action='try_apn' AND centroid_wkt_4326 IS NULL
          THEN 'no geocode, no apn, hand flagged to try apn'
         WHEN simple_action='try_geocode_fix' AND manual_lat IS NULL and centroid_wkt_4326 IS NULL
          THEN 'no geocode, no apn, hand flagged to try address string fix'
         ELSE source END) as source
FROM location.geocoded_with_hand_review m
go

CREATE VIEW location.geocoded_single_result AS
WITH latlong_ce (joinid, latitude,
  longitude,source)
AS
(
    SELECT joinid,
         (CASE
    WHEN lat_pf IS NOT NULL THEN lat_pf
    WHEN lat_gm IS NOT NULL THEN lat_gm
    ELSE lat_mz END) as latitude,
         (CASE
    WHEN lon_pf IS NOT NULL THEN lon_pf
    WHEN lon_gm IS NOT NULL THEN lon_gm
    ELSE lon_mz END) as longitude,
         (CASE
    WHEN lon_pf IS NOT NULL THEN 'abag'
    WHEN lon_gm IS NOT NULL THEN 'google'
    ELSE 'mapzen' END) as source
  FROM location.geocoded
)
SELECT joinid,
       source,
       latitude,
       longitude
FROM latlong_ce
WHERE latitude IS NOT NULL
AND longitude IS NOT NULL
AND latitude>-90 and latitude <90
go

create view location.permitfeature_deduped AS
WITH dedup AS (
    SELECT p.joinid,
           p.Lat,
           p.Long,
           ROW_NUMBER() OVER(PARTITION BY p.joinid
                                 ORDER BY p.joinid DESC) AS rk
      FROM permitFeature p)
SELECT d.joinid,
       d.Lat,
       d.Long
  FROM dedup d
 WHERE d.rk = 1
go

create view location.hand_review_11_27_2017_simple_actions_deduped AS
WITH dedup AS (
    SELECT p.joinid,
           p.note,
           p.simple_action,
           ROW_NUMBER() OVER(PARTITION BY p.joinid
                                 ORDER BY p.joinid DESC) AS rk
      FROM location.hand_review_11_27_2017_simple_actions p)
SELECT d.joinid,
       d.note,
       d.simple_action
  FROM dedup d
 WHERE d.rk = 1
go

CREATE VIEW location.no_location_found_12_05_17 AS
SELECT joinid,
  simple_action,
  note
FROM location.geocoded_with_hand_review
WHERE
  (joinid in (select joinid from location.not_in_bay_area_11_29_cache)
           AND centroid_wkt_4326 IS NULL
           AND manual_lat IS NULL)
  OR (simple_action='try_apn' AND centroid_wkt_4326 IS NOT NULL and manual_lat IS NOT NULL)
  OR (simple_action='try_geocode_fix' AND manual_lat IS NOT NULL and centroid_wkt_4326 IS NOT NULL)
go

create view location.bay_area_boundaries
  as select geometry::UnionAggregate(shape) as shape
    from county
go

create view location.permits_needing_location_fixes AS
select *,
  (CASE WHEN joinid in (select joinid from location.not_in_bay_area_11_29_cache) THEN 1
  ELSE 0 END) as outside_bay_area
from
  location.geocoded_with_hand_review
WHERE source <> 'abag'
AND (
  centroid_wkt_4326 IS NOT NULL
  OR simple_action <> ''
  OR note <> ''
  OR manual_lat IS NOT NULL
  OR manual_lon IS NOT NULL
  OR joinid in (select joinid from location.not_in_bay_area_11_29_cache)
      )
go

create view location.fixed_by_manual AS
select cnt.joinid, geometry::Point(cnt.lon, cnt.lat, 4326) as Shape
  FROM location.permits_needing_location_fixes pnf
  LEFT JOIN location.manual_latlongs_deduped cnt
    ON cnt.joinid=pnf.joinid
  WHERE cnt.lat IS NOT NULL
go

create view location.fixed_by_apn AS
select cnt.joinid, geometry::STGeomFromText(cnt.centroid_wkt_4326, 4326) as Shape
  FROM location.permits_needing_location_fixes pnf
  LEFT JOIN location.apn_centroids_deduped cnt
    ON cnt.joinid=pnf.joinid
  WHERE cnt.centroid_wkt_4326 IS NOT NULL
go

CREATE VIEW location.not_fixed AS
SELECT * from location.permits_needing_location_fixes p
  where p.joinid NOT IN (
SELECT joinid FROM fixed_by_apn
  UNION
SELECT joinid from fixed_by_manual
)
go

CREATE VIEW location.fixed AS
SELECT joinid, Shape from location.fixed_by_manual
  WHERE joinid not in (select joinid from location.fixed_by_apn)
  UNION ALL
SELECT joinid, Shape from location.fixed_by_apn
go

CREATE VIEW location.good_and_fixed AS
SELECT joinid, Shape, 'abag_google' as process_source
  FROM location.good_abag_and_geocoded_locations
    WHERE joinid NOT IN
          (SELECT joinid FROM location.fixed)
  UNION ALL
SELECT joinid, Shape, 'fixed' as process_source
  FROM location.fixed
go

CREATE VIEW location.good_and_fixed_in_bay_area AS
SELECT f.*
FROM location.good_and_fixed f, 
  geocoding_summary.bay_area_boundaries g
WHERE f.Shape.STWithin(g.shape)=1
go

