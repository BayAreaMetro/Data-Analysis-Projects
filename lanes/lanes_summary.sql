  CREATE VIEW nw_lanes_ops_ewkt AS
  WITH boundary AS (
      SELECT ST_Union(shape) as shape
      FROM tomtom_2016.tt_a8 WHERE order08 IN ('CA001','CA013','CA041','CA055','CA075','CA081','CA085','CA095','CA097')
      )
    SELECT
        nw.objectid,
        ST_AsEWKT(nw.shape) as shape_ewkt,
        nw.id,
        nw.frc,
        nw.name,
        nw.shieldnum,
        nw.freeway,
        nw.tollrd,
        nw.oneway,
        nw.lanes,
        nw.ramp,
        nw.fow,
        nw.kph,
        nw.speedcat,
        nw.minutes,
        nw.partstruc,
        ll.id AS ll_id,
        ll.seqnr AS ll_seqnr,
        ll.dividertyp,
        ld.id AS ld_id,
        ld.seqnr AS ld_seqnr,
        ld.direction,
        li.id AS li_id,
        li.seqnr AS li_seqnr,
        li.lanetyp,
        li.singoc,
        li.minvehoc,
        pm.id AS pm_id,
        pm.seqnr AS pm_seqnr,
        pm.payment,
        le.id AS le_id,
        le.seqnr AS le_seqnr,
        le.laneend,
        lp.id AS lp_id,
        lp.seqnr AS lp_seqnr,
        lp.trpelid,
        lp.trpeltyp,
        ln.id AS ln_id,
        ln.feattyp,
        ln.fromto
    FROM
        boundary,
        tomtom_2016.tt_nw nw
    LEFT JOIN
        tomtom_2016.tt_ll ll
            ON nw.id = ll.id
    LEFT JOIN
        tomtom_2016.tt_ld ld
            ON nw.id = ld.id
    LEFT JOIN
        tomtom_2016.tt_li li
            ON nw.id = li.id
    LEFT JOIN
        tomtom_2016.tt_pm pm
            ON nw.id = pm.id
    LEFT JOIN
        tomtom_2016.tt_le le
            ON nw.id = le.id
    LEFT JOIN
        tomtom_2016.tt_lp lp
            ON nw.id = lp.trpelid
    LEFT JOIN
        tomtom_2016.tt_ln ln
            ON lp.id = ln.id
    WHERE
        nw.frc = ANY (
            ARRAY[0, 1, 2, 3, 4, 5, 6]
        )
    AND ST_Within(nw.shape,boundary.shape);