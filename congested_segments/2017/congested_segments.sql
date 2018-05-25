SELECT
    RIGHT(rdstmc, LENGTH(rdstmc) - 1) as tmcid,
    ST_AsText(nw.shape) as geom 
FROM
    tomtom_2016.tt_nw nw 
RIGHT JOIN
    tomtom_2016.tt_rd rd 
        ON nw.id = rd.id 
WHERE RIGHT(rdstmc, LENGTH(rdstmc) - 1) IN ({tmc_ids*})