create sequence alameda_2010_objectid_seq
;

create sequence alameda_2015_objectid_seq
;

create sequence contracosta_2010_objectid_seq
;

create sequence contracosta_2015_objectid_seq
;

create sequence marin_2010_objectid_seq
;

create sequence marin_2015_objectid_seq
;

create sequence napa_2010_objectid_seq
;

create sequence napa_2015_objectid_seq
;

create sequence sanfrancisco_2010_objectid_seq
;

create sequence sanfrancisco_2015_objectid_seq
;

create sequence sanmateo_2010_objectid_seq
;

create sequence sanmateo_2015_objectid_seq
;

create sequence santaclara_2010_objectid_seq
;

create sequence santaclara_2015_objectid_seq
;

create sequence solano_2010_objectid_seq
;

create sequence solano_2015_objectid_seq
;

create sequence sonoma_2010_objectid_seq
;

create sequence sonoma_2015_objectid_seq
;

create table alameda_2010
(
	objectid integer default nextval('alameda_2010_objectid_seq'::regclass) not null
		constraint alameda_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

create table alameda_2015
(
	objectid integer default nextval('alameda_2015_objectid_seq'::regclass) not null
		constraint alameda_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table contracosta_2010
(
	objectid integer default nextval('contracosta_2010_objectid_seq'::regclass) not null
		constraint contracosta_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;



create table contracosta_2015
(
	objectid integer default nextval('contracosta_2015_objectid_seq'::regclass) not null
		constraint contracosta_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table marin_2010
(
	objectid integer default nextval('marin_2010_objectid_seq'::regclass) not null
		constraint marin_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;



create table marin_2015
(
	objectid integer default nextval('marin_2015_objectid_seq'::regclass) not null
		constraint marin_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

create table napa_2010
(
	objectid integer default nextval('napa_2010_objectid_seq'::regclass) not null
		constraint napa_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

create table napa_2015
(
	objectid integer default nextval('napa_2015_objectid_seq'::regclass) not null
		constraint napa_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table sanfrancisco_2010
(
	objectid integer default nextval('sanfrancisco_2010_objectid_seq'::regclass) not null
		constraint sanfrancisco_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

create table sanfrancisco_2015
(
	objectid integer default nextval('sanfrancisco_2015_objectid_seq'::regclass) not null
		constraint sanfrancisco_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

create table sanmateo_2010
(
	objectid integer default nextval('sanmateo_2010_objectid_seq'::regclass) not null
		constraint sanmateo_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table sanmateo_2015
(
	objectid integer default nextval('sanmateo_2015_objectid_seq'::regclass) not null
		constraint sanmateo_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;



create table santaclara_2010
(
	objectid integer default nextval('santaclara_2010_objectid_seq'::regclass) not null
		constraint santaclara_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table santaclara_2015
(
	objectid integer default nextval('santaclara_2015_objectid_seq'::regclass) not null
		constraint santaclara_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;



create table solano_2010
(
	objectid integer default nextval('solano_2010_objectid_seq'::regclass) not null
		constraint solano_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table solano_2015
(
	objectid integer default nextval('solano_2015_objectid_seq'::regclass) not null
		constraint solano_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;


create table sonoma_2010
(
	objectid integer default nextval('sonoma_2010_objectid_seq'::regclass) not null
		constraint sonoma_2010_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;



create table sonoma_2015
(
	objectid integer default nextval('sonoma_2015_objectid_seq'::regclass) not null
		constraint sonoma_2015_pkey
			primary key,
	county varchar(4),
	apn1 varchar(25),
	apn2 varchar(25),
	apn3 varchar(25),
	apn4 varchar(25),
	gacres double precision,
	shape geometry
		constraint enforce_srid_shape
			check (public.st_srid(shape) = 3857)
)
;

