CREATE VIEW analysis.regional_units_and_permits_by_affordability AS
SELECT
  joinid,
  CASE
    WHEN (verylow > 0 AND low > 0)
    OR (low > 0 AND moderate > 0)
    OR (moderate > 0 AND abovemod > 0)
    OR (verylow > 0 AND moderate > 0)
    OR (verylow > 0 AND abovemod > 0)
    OR (low > 0 AND abovemod > 0)
    THEN 'multiple permit categories'
    WHEN verylow>0 THEN 'very low'
    WHEN low>0 THEN 'low'
    WHEN moderate>0 THEN 'moderate'
    WHEN abovemod>0 THEN 'above moderate'
    ELSE 'unknown'
  END AS permit_affordability_category,
  verylow as verylow_units,
  low as low_units,
  moderate as moderate_units,
  abovemod as abovemod_units,
  totalunit as total_units,
   CAST(
      CAST(permyear AS VARCHAR(4)) + '-01-01'
   AS date) as permit_year
  FROM import.Permits_10_18_2017
go



CREATE VIEW analysis.permits_issued_2015_by_jurisdiction_and_category AS
WITH Permits_CTE (jurisdiction_name,very_low,low,moderate,above_moderate) AS
(SELECT [Jurisdiction Name] as jurisdiction_name,
very_low_non_dr + very_low_dr as very_low,
low_non_dr + low_dr as low,
moderate_non_dr + moderate_dr as moderate,
above_moderate_total as above_moderate
FROM import.rhna_2015_2035)
SELECT jurisdiction_name, very_low,low,moderate,above_moderate,
very_low + low + moderate + above_moderate as total
FROM Permits_CTE
go


CREATE VIEW analysis.housing_categories_by_year AS
  WITH HC_CTE (hcategory, permit_year) AS (
    SELECT CAST(hcategory as varchar(256)) as hcategory,
      CAST(
          CAST(permyear AS
            VARCHAR(4)) + '-01-01'
          AS date
        ) as [permit_year]
       FROM import.Permits_10_18_2017)
SELECT hcategory, [permit_year], count(*) as count
FROM HC_CTE
GROUP BY hcategory, [permit_year]
go

CREATE VIEW analysis.permits_by_jurisdiction_year_affordability AS
with j_CTE (name,permyear,joinid,permit_category) AS
(SELECT
   j.name,
   p.permyear,
   g.joinid,
   r.permit_affordability_category
 FROM
   jurisdiction j,
   geocode_spatial_tables.main g,
   import.Permits_10_18_2017 p,
   analysis.regional_units_and_permits_by_affordability r
WHERE g.joinid=p.joinid
  AND r.joinid=p.joinid
AND g.Shape.STWithin(j.shape) = 1
)
select name, permyear, permit_category, count(*) as permits
from j_CTE
GROUP BY name, permyear, permit_category
go

CREATE VIEW analysis.units_by_jurisdiction_year_affordability AS
with j_CTE (name,permyear,totalunit,joinid,permit_category) AS
(SELECT
   j.name,
   p.permyear,
   p.totalunit,
   g.joinid,
   r.permit_affordability_category
 FROM
   jurisdiction j,
   geocode_spatial_tables.main g,
   import.Permits_10_18_2017 p,
   analysis.regional_units_and_permits_by_affordability r
WHERE g.joinid=p.joinid
  AND r.joinid=p.joinid
AND g.Shape.STWithin(j.shape) = 1
)
select name, permyear, permit_category, sum(totalunit) as total_units
from j_CTE
GROUP BY name, permyear, permit_category
go

CREATE VIEW analysis.units_by_jurisdiction_year_affordability_permit_feature AS
with j_CTE (name,permyear,totalunit,joinid,permit_category) AS
(SELECT
   j.name,
   p.permyear,
   p.totalunit,
   g.joinid,
   r.permit_affordability_category
 FROM
   jurisdiction j,
   permitFeature g,
   import.Permits_10_18_2017 p,
   analysis.regional_units_and_permits_by_affordability r
WHERE g.joinid=p.joinid
  AND r.joinid=p.joinid
AND g.Shape.STWithin(j.shape) = 1
)
select name, permyear, permit_category, sum(totalunit) as total_units
from j_CTE
GROUP BY name, permyear, permit_category
go

