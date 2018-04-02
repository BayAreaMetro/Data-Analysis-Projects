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
