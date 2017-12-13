CREATE VIEW geocode_results.gmaps_all_years AS
            select joinid, 
              latitude, 
              longitude,
              location_type,
              partial_addr 
              from geocode_results.gmaps g1
            UNION 
              select joinid, 
              latitude, 
              longitude,
              location_type,
              partial_addr
            from geocode_results.gmaps_2016
go

CREATE VIEW geocode_results.mapzen_all_years AS
            select joinid, 
              latitude, 
              longitude
              from geocode_results.mapzen
            UNION 
              select joinid, 
              latitude, 
              longitude
            from geocode_results.mapzen_2016
go

