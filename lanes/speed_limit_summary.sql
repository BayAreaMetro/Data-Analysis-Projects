    CREATE VIEW nw_tmc_speed_limit_ewkt AS WITH boundary AS (   SELECT
        ST_Union(shape) as shape   
    FROM
        tomtom_2016.tt_a8 
    WHERE
        order08 IN ('CA001','CA013','CA041','CA055','CA075','CA081','CA085','CA095','CA097') ) SELECT
        rd.rdstmc,
        sr.speed,
        sr.speedtyp,
        sr.valdir,
        sr.verified,
        ST_AsEWKT(nw.shape) as shape_ewkt 
    FROM
        boundary,
        tomtom_2016.tt_nw nw 
    LEFT JOIN
        tomtom_2016.tt_rd rd 
            ON nw.id = rd.id 
    LEFT JOIN
        tomtom_2016.tt_sr sr 
            ON nw.id = sr.id 
    WHERE
        ST_Within(nw.shape,boundary.shape);
    
