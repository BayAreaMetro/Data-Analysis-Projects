-----------------------
CREATE VIEW public.tom_all_2010_parcels AS
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.alameda_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.contracosta_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.marin_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.napa_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.sanfrancisco_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.sanmateo_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.santaclara_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.solano_2010
UNION ALL
SELECT county, apn1, apn2, apn3, apn4, gacres, shape
FROM
parcl.sonoma_2010

----------------------
CREATE TABLE public.tom_all_2010_parcels_apn_indexed AS
select county, apn1, apn2, apn3, apn4, gacres, shape
FROM public.tom_all_parcels

---------------------------
CREATE INDEX apn1_2010_idx ON tom_all_2010_parcels_apn_indexed (apn1);
CREATE INDEX apn2_2010_idx ON tom_all_2010_parcels_apn_indexed (apn2);
CREATE INDEX apn3_2010_idx ON tom_all_2010_parcels_apn_indexed (apn3);
CREATE INDEX apn4_2010_idx ON tom_all_2010_parcels_apn_indexed (apn4);

CREATE VIEW tom_permits_12_8_2010_apn_all AS
SELECT
hp.joinid, hp.apn,
p.apn1, p.apn2, p.apn3, p.apn4,
st_astext(st_pointonsurface(st_transform(p.shape, 4326))) as point_on_surface_wkt_4326,
st_astext(st_centroid(st_transform(p.shape, 4326))) as centroid_wkt_4326
FROMdf_gm
	(select * from public.tom_permits_12_8_2017 hp where apn NOT LIKE 'NULL') hp
LEFT JOIN public.tom_all_2010_parcels_apn_indexed p
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
			OR REPLACE(hp.apn, ' ', '-') = p.apn4;