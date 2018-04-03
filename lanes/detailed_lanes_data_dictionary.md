## RDSTMC

Definition of RDSTMC value "ABCCDEEEEE" for Level 1 Elements:

    A = Direction of Road Element (from start Junction to end Junction) compared with the TMC chain direction:
        + = in positive direction and external to the TMC point location;
        - = in negative direction and external to the TMC point location;
    B = EBU (European Broadcasting Union) Country Code;
    CC = TMC Location Code;
    D = TMC Direction of the Chain;
        + = in positive direction and external to the TMC point location;
        - = in negative direction and external to the TMC point location;
        P = in positive direction and internal to the TMC point location;
        N = in negative direction and internal to the TMC point location.
    EEEEE = TMC Point Location Code (found in the official TMC location Databases).
    See TMC Location Structure in MultiNet® Shapefile Data later in this user guide for a description and comparison with Complex Feature location codes.

## kph

The KPH field in the Shapefile Network file (nw) represents the average speed over the entire distance of a road. This calculation is based on the Functional Road Class (FRC), Form of Way (FOW) and whether the Road Elements travel through Built Up Areas (BUAs).

## feattype

Maneuver feature types include: Bifurcation, Priority, Prohibited, Restricted, Calculated or Derived Prohibited and Image Maneuver.


## Speed Restrictions 

the sr table contains speed information for Vehicle Types, Direction of Speed Restriction Validity, type of speed restriction and the speed for the selected transportation element.
SPEED

The unit of measure for the SPEED attribute is defined in the country (Administrative Order A0) area feature's MUNIT field. The SPEED field represents either the maximum, recommended or lane-dependent speed for a single Road Element. Note that a particular Road Element can be flagged in the nw file with an average speed that may be higher than the sr maximum speed value.

### SPEEDTYP

Speed restriction types tagged "undefined" ("0") can be due to no existing sign posts indicating a maximum or recommended speed.

### VALDIR
The VALDIR field indicates whether the speed restriction is valid in the positive, negative or both directions of the related transportation element.

A road element flagged as a oneway may be assigned speed restrictions in both directions. The speed restrictions that are assigned to the opposite direction of the oneway road element can be ignored.

### VERIFIED

The VERIFIED field in the Shapefile Speed Restriction file (sr) indicates whether the speed values were verified by reliable sources ("1") or were calculated ("0" - not verified).

Example: In the U.S., a Major Slip Road is an example of a road tagged both with a SPEEDTYP = "0" (undefined) and VERIFIED = "0" (not verified).
