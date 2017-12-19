CREATE TABLE permits_2016_shape AS
SELECT pf.joinid, ST_GeomFromText(pf.wkt, 4326) as shape
  FROM permitfeature pf
  INNER JOIN (SELECT * FROM permit WHERE permyear=2016) p
ON pf.joinid=p.joinid;

CREATE INDEX permits_2016_shape_sidx
ON permits_2016_shape USING GIST (shape);

CREATE INDEX regional_housing_need_assessment_20072014__housing_elem_sidx 
ON regional_housing_need_assessment_20072014__housing_element_site USING GIST (geom);

CREATE INDEX regional_housing_need_assessment_20152023__housing_elem_sidx 
ON regional_housing_need_assessment_20152023__housing_element_site USING GIST (geom);

CREATE TABLE permits_rhna_fields_2016 AS
select ps.joinid,
  'Y' as rhna,
  'RHNA5' as rhnacyc
from permits_2016_shape ps,
regional_housing_need_assessment_20152023__housing_element_site rh5
WHERE st_intersects(rh5.geom,ps.shape)
UNION ALL
select ps.joinid,
  'Y' as rhna,
  'RHNA4' as rhnacyc
from permits_2016_shape ps,
regional_housing_need_assessment_20072014__housing_element_site rh4
WHERE st_intersects(rh4.geom,ps.shape)

CREATE VIEW permits_rhna_fields_2016_deduped AS
  WITH in_both_rhna_4_and_5_element_sites as
      (SELECT joinid
          FROM permits_rhna_fields_2016
            GROUP BY joinid
          HAVING count(*)>1)
SELECT DISTINCT joinid,
        rhna,
        'RHNA4&5' as rhnacyc
FROM permits_rhna_fields_2016
  WHERE joinid IN (
    select joinid
    FROM in_both_rhna_4_and_5_element_sites
  )
UNION ALL
  SELECT joinid,
       rhna,
       rhnacyc
FROM permits_rhna_fields_2016
  WHERE joinid NOT IN (
    SELECT joinid
    FROM  in_both_rhna_4_and_5_element_sites
  )

---sanity check of above
select p.joinid, p.rhnacyc as rhnacyc1, pd.rhnacyc as rhnacyc2
  FROM permits_rhna_fields_2016 p
  left join permits_rhna_fields_2016_deduped pd
    ON p.joinid=pd.joinid