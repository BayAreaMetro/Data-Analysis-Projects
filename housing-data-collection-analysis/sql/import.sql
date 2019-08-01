create table Permits_10_18_2017
(
  joinid nvarchar(255),
  permyear int,
  permdate text,
  county int,
  jurisdictn text,
  apn text,
  address text,
  zip text,
  projname text,
  hcategory text,
  verylow int,
  low int,
  moderate int,
  abovemod int,
  totalunit int,
  infill int,
  affrdunit int,
  deedaffrd int,
  asstaffrd int,
  opnaffrd int,
  tenure text,
  rpa text,
  rhna text,
  rhnacyc text,
  pda text,
  pdaid text,
  tpa text,
  hoa text,
  occertiss text,
  occertyr text,
  occertdt text,
  mapped text,
  notes text,
  datacollectionyr int
)
go

create index Permits_10_18_2017_joinid_index
  on Permits_10_18_2017 (joinid)
go

create table rhna_2015_2035
(
  [Jurisdiction Name] nvarchar(255),
  very_low_rhna int,
  very_low_non_dr int,
  very_low_dr int,
  low_rhna int,
  low_non_dr int,
  low_dr int,
  moderate_rhna int,
  moderate_non_dr int,
  moderate_dr int,
  above_moderate_rhna int,
  above_moderate_total int
)
go

create table rhna_2007_2014
(
  jurisdiction text,
  very_low_RHNA int,
  very_low_permits int,
  low_RHNA int,
  low_Permits int,
  moderate_RHNA int,
  moderate_Permits int,
  above_moderate_RHNA int,
  above_moderate_Permits int,
  total_RHNA int,
  total_Permits int,
  qualifier text
)
go

create table geocoding_hand_review_11_27_2017
(
  joinid varchar(256),
  note varchar(max),
  action varchar(max),
  new_address varchar(max),
  zipcode int,
  new_city varchar(max)
)
go

create index geocoding_hand_review_11_27_2017_joinid_index
  on geocoding_hand_review_11_27_2017 (joinid)
go

create table apn_lookup_2015_parcels1
(
  hpjoinid varchar(256),
  apn text,
  apn1 varchar(25),
  apn2 varchar(25),
  apn3 varchar(25),
  apn4 varchar(25),
  point_on_surface_wkt_4326 text,
  centroid_wkt_4326 text
)
go

create index apn_lookup_2015_parcels1_hpjoinid_index
  on apn_lookup_2015_parcels1 (hpjoinid)
go

create table try_geocode_fix_manual_11_29_2017
(
  joinid varchar(256),
  manual_lon float,
  manual_lat float,
  not_locatable int,
  [use apn] int,
  vague int,
  [error-see notes] int
)
go

create index try_geocode_fix_manual_11_29_2017_joinid_index
  on try_geocode_fix_manual_11_29_2017 (joinid)
go

create table outside_bay_area_fixes
(
  joinid varchar(256),
  manual_lat2 float,
  manual_lon2 float,
  vague int,
  not_locatable int,
  try_apn int
)
go

create index outside_bay_area_fixes_joinid_index
  on outside_bay_area_fixes (joinid)
go

create table jurisdictionPolicy
(
  id int identity,
  jurisdictionId int,
  policyID int,
  categoryID int
)
go

create table outside_bay_with_apn_lookup_2015_parcels
(
  joinid varchar(256),
  apn text,
  apn1 text,
  apn2 text,
  apn3 text,
  apn4 text,
  point_on_surface_wkt_4326 text,
  centroid_wkt_4326 text
)
go

create index outside_bay_with_apn_lookup_2015_parcels_joinid_index
  on outside_bay_with_apn_lookup_2015_parcels (joinid)
go

create table manual_review_tb
(
  joinid nvarchar(255),
  note varchar(69),
  action varchar(15)
)
go

create index manual_review_tb_joinid_index
  on manual_review_tb (joinid)
go

create index manual_review_tb_joinid_index2
  on manual_review_tb (joinid)
go

create table ResidentialPermits_attTbl
(
  joinid varchar(50),
  permyear varchar(50),
  permdate varchar(50),
  county varchar(50),
  jurisdictn varchar(50),
  apn varchar(50),
  address varchar(50),
  zip varchar(50),
  projname varchar(50),
  hcategory varchar(50),
  verylow varchar(50),
  low varchar(50),
  moderate varchar(50),
  abovemod varchar(50),
  totalunit varchar(50),
  infill varchar(50),
  affrdunit varchar(50),
  deedaffrd varchar(50),
  asstaffrd varchar(50),
  opnaffrd varchar(50),
  tenure varchar(50),
  rpa varchar(50),
  rhna varchar(50),
  rhnacyc varchar(50),
  pda varchar(50),
  pdaid varchar(50),
  tpa varchar(50),
  hoa varchar(50),
  occertiss varchar(50),
  occertyr varchar(50),
  occertdt varchar(50),
  mapped varchar(50)
)
go

create table tb_manual_review_round3
(
  number int,
  joinid varchar(256),
  spatialJoinId text,
  permyear int,
  county int,
  jurisdictn text,
  apn text,
  address text,
  zip int,
  projname text,
  hcategory text,
  notes text,
  tom_notes text
)
go

create table Permits_12_8_2017
(
  ks_index int,
  joinid varchar(256),
  permyear int,
  permdate varchar(256),
  county int,
  jurisdictn varchar(256),
  apn varchar(256),
  address text,
  zip int,
  projname text,
  hcategory varchar(256),
  verylow int,
  low int,
  moderate int,
  abovemod int,
  totalunit int,
  infill int,
  affrdunit int,
  deedaffrd int,
  asstaffrd int,
  opnaffrd int,
  tenure varchar(1),
  rpa varchar(1),
  rhna varchar(1),
  rhnacyc varchar(7),
  pda varchar(1),
  pdaid char(1),
  tpa char(1),
  hoa char(1),
  occertiss char(1),
  occertyr char(1),
  occertdt char(1),
  mapped char(1),
  notes varchar(256)
)
go

create index PermitsDB_12_18_2017_joinid_index
  on Permits_12_8_2017 (joinid)
go

create table permits_12_8_2015_apn_centroids_and_point_on_surface
(
  joinid varchar(256),
  apn varchar(256),
  apn1 varchar(25),
  apn2 varchar(25),
  apn3 varchar(25),
  apn4 varchar(25),
  point_on_surface_wkt_4326 text,
  centroid_wkt_4326 text,
  shape geometry
)
go

create index permits_12_8_2015_apn_centroids_and_point_on_surface_joinid_index
  on permits_12_8_2015_apn_centroids_and_point_on_surface (joinid)
go

create table HOUSING_2014_2015_MZ
(
  OBJECTID int not null,
  joinid nvarchar(11),
  Lat numeric(38,8),
  Long numeric(38,8),
  Shape geometry,
  WKT nvarchar(250)
)
go

create table HOUSING_JOSH_UPDATES_MZ
(
  OBJECTID int not null,
  joinid nvarchar(254),
  permyear nvarchar(254),
  permdate nvarchar(254),
  county nvarchar(254),
  jurisdictn nvarchar(254),
  apn nvarchar(254),
  address nvarchar(254),
  zip nvarchar(254),
  projname nvarchar(254),
  hcategory nvarchar(254),
  verylow numeric(38,8),
  low numeric(38,8),
  moderate numeric(38,8),
  abovemod numeric(38,8),
  totalunit numeric(38,8),
  process_so nvarchar(11),
  ESRI_OID int,
  Shape geometry
)
go

create table HOUSING_MS_UPDATES_MZ
(
  OBJECTID int not null,
  joinid nvarchar(254),
  permyear nvarchar(254),
  permdate nvarchar(254),
  county nvarchar(254),
  jurisdictn nvarchar(254),
  apn nvarchar(254),
  address nvarchar(254),
  zip nvarchar(254),
  projname nvarchar(254),
  hcategory nvarchar(254),
  verylow numeric(38,8),
  low numeric(38,8),
  moderate numeric(38,8),
  abovemod numeric(38,8),
  totalunit numeric(38,8),
  process_so nvarchar(11),
  ESRI_OID int,
  Shape geometry
)
go

create table project_mapper
(
  ID nvarchar(60) not null,
  WKT nvarchar(max),
  Shape geometry,
  Project nvarchar(100),
  [_id] int not null,
  Date datetime2
)
go

create table permits_12_8_2010_apn_centroids_and_point_on_surface
(
  joinid varchar(256),
  apn varchar(256),
  apn1 varchar(25),
  apn2 varchar(25),
  apn3 varchar(25),
  apn4 varchar(25),
  point_on_surface_wkt_4326 text,
  centroid_wkt_4326 text
)
go

create view import.Permits_10_18_2017_nulls AS
select *
from import.Permits_10_18_2017
WHERE apn LIKE 'NULL'
and address LIKE 'NULL'
and permyear > 2015
go

CREATE VIEW import.permits_12_8_parcels_2010_2015_apn_centroids_and_point_on_surface AS
select joinid, apn, apn1, apn2, apn3, apn4, point_on_surface_wkt_4326, centroid_wkt_4326
from import.permits_12_8_2010_apn_centroids_and_point_on_surface
where joinid
NOT IN (SELECT joinid
        from import.permits_12_8_2015_apn_centroids_and_point_on_surface)
UNION ALL
select joinid, apn, apn1, apn2, apn3, apn4, point_on_surface_wkt_4326, centroid_wkt_4326
from import.permits_12_8_2015_apn_centroids_and_point_on_surface
go

create view import.permits_12_8_parcels_2010_2015_apn_centroids_and_point_on_surface_deduped AS
WITH dedup AS (
    SELECT p.joinid, p.apn, p.apn1, p.apn2, p.apn3, p.apn4, p.point_on_surface_wkt_4326, p.centroid_wkt_4326,
           ROW_NUMBER() OVER(PARTITION BY p.joinid
                                 ORDER BY p.joinid DESC) AS rk
      FROM import.permits_12_8_parcels_2010_2015_apn_centroids_and_point_on_surface p)
SELECT d.joinid, d.apn, d.apn1, d.apn2, d.apn3, d.apn4, d.point_on_surface_wkt_4326, d.centroid_wkt_4326
  FROM dedup d
 WHERE d.rk = 1
go

