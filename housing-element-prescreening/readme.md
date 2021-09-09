**Document Status: (Draft)**  

# Housing Element Site Selection Pre-Screening Tool & Mapping

## Problem Statement
Provide a map-based Housing Element Site Selection Tool to guide Bay Area local jurisdictions in identifying potential sites for new housing in Housing Elements that align with state requirements and support regional growth, equity, and GHG reduction priorities. 

**Key issues to resolve include**:  
- Ensuring cities have adequate information to identify if a site meetings minimum state requirements - including - -
- Affirmatively Forwarding Fair Housing - and, if not, what steps need to be taken to ensure eligibility. (primary issue)
- Integrating regional equity and GHG reduction priorities (primary issue)
- Getting official, or at least unofficial, sign off from the state (HCD) on our inputs and outputs (primary issue, but after first two bullets)
- Providing robust implementation strategies/policies for cities to consider based upon (secondary issue; can be added to minimum viable product)

### Project Management

[Asana Project Plan](https://app.asana.com/0/1175472246945284/1175472246945284) (Internal Staff Only)

#### MTC Staffing - Roles/ Responsibilities:  
**Project Management**:  
Somaya Abdelgany (Project Manager)  
Mark Shorett (Lead Analysis)  
Heather Peters (REAP Project Manager)     

**DataViz Support**:    
Michael Ziyambi (Web Design/ Application Development)/   
Michael Smith (Data Collection/ Metadata)/  
Eli Kaplan (Data Collection/ Data Analysis/ Mapping)/  
Joshua Croff (Data Analysis/ Mapping)/  
Kaya Tollas (Data Engineering/ Analysis Models)/  
Christy Lefall (AFFH Data Collection and Review)/  
Vikrant Sood (QA/QC)    

## Data Sources


| Factor/ Input | Source/ Data Steward (DS) | Description | Unit of Analysis| Data Path | In MDM (Yes/ No/ TBD) |
|----------|------------|------|------|------|------|
|Community Resource Level/Opportunity(fair housing)| HCD/TCAC Opportunity Maps (built from census, other sources) | | tract | No  
| Transit Access | MTC/ABAG Regional Transit Database; GTFS/ Joshua Croff (DS) | | buffers | | yes  
| Transit Stops |MTC/ABAG Regional Transit Database; GTFS/ Joshua Croff (DS) | | | | TBD  
| Transit Routes |MTC/ABAG Regional Transit Database; GTFS/ Joshua Croff (DS) | | | | TBD  
| Job Proximity - Transit | MTC Travel Model/ Lisa Zorn (DS) | | | |TBD  
| Job Proximity - Auto | MTC Travel Model/ Lisa Zorn (DS) | | | | TBD  
| VMT | MTC Travel Model/ Lisa Zorn (DS) | | | | TBD  
| Low-income units at risk of conversion | CHPC/ Mark Shorett (DS) | | | | TBD  
| Affordable Housing funding eligibility (e.g. LIHTC, AHSC) | HCD; SGC/ Mark Shorett (DS) | | | | TBD  
| Displacement Risk | UC-Berkeley/UDP/ Mark Shorett (DS) | | | | TBD  
| Natural Hazard Risk |MTC; USGS liquefaction susceptibility; CAL FIRE FRAP LRA/SRA data; FEMA (flood zones), Alquist-Priolo Fault Zones (California Geological Survey)/ Michael Germeraad (DS) | | | | TBD  
| Infrastructure Access | TBD/ Mark Shorett (DS) | | | | TBD  
| Market strength/feasibility | TBD - determining approach/ Mark Shorett (DS) | | | | TBD  
| San Mateo County fair housing assessment |[SMCGOV](https://housing.smcgov.org/sites/housing.smcgov.org/files/_SMC%20Regional%20AFH%20Final%20Report%2020171002.pdf)/ Mark Shorett (DS) | | | | TBD  
| Affirmatively Furthering Fair Housing Data and Mapping Tool (AFFH-T)|Mark Shorett (DS) |  || | TBD  
* See this note for Publishing Status explanation.  


## Analysis Parameters

{ Coordinate with DataViz Team Liaison }   

Analysis parameters are definable, measurable, and can contain a constant or variable characteristic, dimension, property, or value, that is selected from a set of data (or population) because it is considered essential to understanding how to solve a problem. List the parameters that you think are required to solve this problem. Leave this blank if you are unsure of how to determine the analysis parameters for your project. The analyst assigned to the project will document this information.  

[let's discuss further]

## Data Processing [INTERNAL MTC/ABAG]
Review the data processing scripts and outputs [here](https://github.com/BayAreaMetro/hess_application/tree/data/data_processing)

## Methodology applied to solve problem  

{ Coordinate with DataViz Team Liaison }   

The analyst assigned to the project will document this information. The analyst will review the methodology (if applicable) with the project team to ensure that it meets the requirements and expectations of the solution or problem.  

## Expected Outcomes (if any)?  
Provide your expectations (if any) for the results of this work. Your expectations will form the basis for deciding if the work is complete, or if we need to revisit the problem statement and/or refine the methodology used to solve the problem.

 1. Final preliminary input table (with sources, current availability, and actions needed to produce or acquire outstanding data noted)
 2.  Produced concurrently with 1.a: Site Selection Tool Mock-Up (template of web tool;
 3. Database (I am not using the correct nomenclature here; what I'm trying to indicate is that we have compiled the data we identified into the desired structure - with structure defined per DataViz team's specs/protocols)
 4. Concurrent with 2.b Beta Site Selection Tool
 5. Site Selection Tool 1.0 (incorporating data identified and collected through deliverables 1-2)

Subsequent deliverables shown below contingent on input from additional staff and/or consultants; will involve modifying workplan once resources secured

 - Integration of additional functionality/modules (e.g. site feasibility scan and context-based policy toolkit)
 - Site Selection Tool 2.0

## Results  
{ Coordinate with DataViz Team Liaison }   

Determine how close the solution is to the expected outcome. If the solution is acceptable, the work will be considered complete. If the solution is unacceptable, we will need to refine the problem statement or the methodology implemented to find the solution.
