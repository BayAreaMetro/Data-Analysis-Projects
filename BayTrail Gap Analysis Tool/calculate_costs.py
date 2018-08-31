import arcpy
from arcpy import env
import sys

# Set the workspace
#
#BAYTRAIL - to update the location or name of the geodatabase, change it in the lines below
env.workspace = "N:\\GIS\\bay trail\\Alignment\\Bay_Trail.gdb"
feature_class = "N:\\GIS\\bay trail\\Alignment\\Bay_Trail.gdb\\Bay_Trail"

# create variables of costs
#BAYTRAIL - the following 22 lines list the current costs
#BAYTRAIL - to update the cost just change the numbers following the appropriate variable
#BAYTRAIL - for example if the cost for Class 2, Rating A changes from $12/foot to $18/foot
#BAYTRAIL - just find the 2A variable called cost_trail_2a and change it to read cost_trail_2a = 18
cost_trail_1a = 75
cost_trail_1b = 155
cost_trail_1c = 325
cost_trail_1x = 3.5
cost_trail_2a = 12
cost_trail_2b = 60
cost_trail_2c = 125
cost_trail_3a = 3.10
cost_trail_3b = 6
cost_trail_3c = 55
cost_bridge_a = 1100
cost_bridge_b = 1675
cost_boardwalk_a = 975
cost_fence_a = 24.50
cost_fence_b = 16.50
cost_fence_c = 37
cost_fence_d = 60
cost_trail_furnishing = 0.02
cost_design = 0.20
cost_environmental_plan_a = 0.05
cost_environmental_plan_b = 0.10
cost_environmental_plan_c = 0.25

# Function to verify that all required fields are in file
def test_all_correct_fields_are_present():
  fields_required = ["Feasibility_Study_", "Length", "Feet", "CLASS", "SEG_RATING", "BOARDWALK_LENGTH", "FENCE_BARRIER", "FENCE_BARRIER_LENGTH", "TRAIL_FURNISHING",
                     "ENV_PLAN_PERMIT", "COST_1A", "COST_1B", "COST_1C", "COST_1X", "COST_2A", "COST_2B", "COST_2C", "COST_3A", "COST_3B", "COST_3C", "COST_BRIDGE_A",
                      "COST_BRIDGE_B", "COST_BOARDWALK_A", "COST_FENCE_A", "COST_FENCE_B", "COST_FENCE_C", "COST_FENCE_D", "COST_TRAIL_FURNISHING",
                      "COST_ENV_PLAN_PERMIT_A", "COST_ENV_PLAN_PERMIT_B", "COST_ENV_PLAN_PERMIT_C", "CONSTRUCTION_COST", "DESIGN_COST", "TOTAL_COST"]
  fields_required_set = set(fields_required)
  field_list = arcpy.ListFields(feature_class)
  field_list_names = ["start"]
  for field in field_list:
    field_list_names.append(field.name)
  field_list_names_set = set(field_list_names)
  if fields_required_set.issubset(field_list_names_set) == False:
    arcpy.AddMessage("********** SEE ERROR ON LINE BELOW **********")
    arcpy.AddMessage("No calculations were computed. Some required fields are not available in the geodatabase")
    arcpy.AddMessage("The required fields (upper/lower case is important) are: Feasibility_Study_, Feet, CLASS,")
    arcpy.AddMessage ("SEG_RATING, BOARDWALK_LENGTH, FENCE_BARRIER, FENCE_BARRIER_LENGTH, TRAIL_FURNISHING,")
    arcpy.AddMessage ("ENV_PLAN_PERMIT, COST_1A, COST_1B, COST_1C, COST_1X, COST_2A, COST_2B, COST_2C, COST_3A,")
    arcpy.AddMessage ("COST_3B, COST_3C, COST_BRIDGE_A, COST_BRIDGE_B, COST_BOARDWALK_A, COST_FENCE_A, COST_FENCE_B,")
    arcpy.AddMessage ("COST_FENCE_C, COST_FENCE_D, COST_TRAIL_FURNISHING, COST_ENV_PLAN_PERMIT_A, COST_ENV_PLAN_PERMIT_B,")
    arcpy.AddMessage ("COST_ENV_PLAN_PERMIT_C, CONSTRUCTION_COST, DESIGN_COST, TOTAL_COST")
# line below to exit script, wrong fields in geodatabase and script will fail if if continues
    sys.exit(1)

# Function to set all costs to 0 before calculating new costs. Protects against having incorrect
# old values in place after a segment has changed class or rating or removed other info (boardwalks, etc)
def zero_all_costs():
  fields_to_zero = ["COST_1A", "COST_1B", "COST_1C", "COST_1X", "COST_2A", "COST_2B", "COST_2C", "COST_3A", "COST_3B", "COST_3C", "COST_BRIDGE_A",
                      "COST_BRIDGE_B", "COST_BOARDWALK_A", "COST_FENCE_A", "COST_FENCE_B", "COST_FENCE_C", "COST_FENCE_D", "COST_TRAIL_FURNISHING",
                      "COST_ENV_PLAN_PERMIT_A", "COST_ENV_PLAN_PERMIT_B", "COST_ENV_PLAN_PERMIT_C", "CONSTRUCTION_COST", "DESIGN_COST", "TOTAL_COST"]
  row, cur = None, None
  cur = arcpy.UpdateCursor(feature_class)
    
  # Iterate through the rows in the cursor
  for row in cur:
    for field in fields_to_zero:
      current_zero_field = field
      if row.isNull(current_zero_field) == 0:
        row.setNull(current_zero_field)
    cur.updateRow(row)
  del row, cur
      
# Function to transfer the feasibility study cost to Total_Cost field
# Try/Except in place to weed out any non numeric information (i.e. if there is non-numeric text, then
# cost = int(row.Feasibility_Study_) will fail and be caught by the except. Script still runs.
def feasibility_study_costs():
  row, cur = None, None
  cur = arcpy.UpdateCursor(feature_class)
    
  # Iterate through the rows in the cursor
  for row in cur:
    if row.isNull("FEASIBILITY_STUDY_COST") == 0:
      try:
        cost = int(row.FEASIBILITY_STUDY_COST)
        row.setValue("TOTAL_COST", cost)
      except:
        pass
       # arcpy.AddMessage("********** SEE FEASIBILITY ERROR ON LINE BELOW **********")
       # arcpy.AddMessage ("Chances are there is some non-numeric text in the 'Feasibility_Study_' field.")
    cur.updateRow(row)
  del row, cur

# Function to add up calculate env/planning/permitting costs or design costs or construction costs and pass back total to main script
def add_costs():
  total_cost_env_plan_permit = 0
  fields_to_add_for_env_plan_permit_or_design = ["COST_1A", "COST_1B", "COST_1C", "COST_1X", "COST_2A", "COST_2B", "COST_2C", "COST_3A", "COST_3B", "COST_3C", "COST_BRIDGE_A",
                      "COST_BRIDGE_B", "COST_BOARDWALK_A", "COST_FENCE_A", "COST_FENCE_B", "COST_FENCE_C", "COST_FENCE_D", "COST_TRAIL_FURNISHING"]
  for field in fields_to_add_for_env_plan_permit_or_design:
    current_cost = row.getValue(field)
    if row.isNull(field) == 0:
      total_cost_env_plan_permit += current_cost
      print total_cost_env_plan_permit
  return total_cost_env_plan_permit

# Function to get total costs. Add up design, env/plan/permit, and construction costs and pass back total to main script
def add_total_costs():
  total_cost = 0
  fields_to_add_for_total_costs = ["COST_ENV_PLAN_PERMIT_A", "COST_ENV_PLAN_PERMIT_B", "COST_ENV_PLAN_PERMIT_C", "DESIGN_COST", "CONSTRUCTION_COST"]
  for field in fields_to_add_for_total_costs:
    current_cost = row.getValue(field)
    if row.isNull(field) == 0:
      total_cost += current_cost
  return total_cost
  
# Function to recalculate the length in feet of every segment
def calculate_lengths():
    arcpy.CalculateField_management(feature_class, "Feet", "!shape.length@feet!", "PYTHON_9.3")
    arcpy.CalculateField_management(feature_class, "Length", "!shape.length@miles!", "PYTHON_9.3")

######################################
##### START OF MAIN CODE BELOW
######################################

# test that all required fields to run this script are present in the geodatabase
test_all_correct_fields_are_present()
    
# empty all cost fields before processing, this is to ensure that any class or ratings that have changed
zero_all_costs()

# recalculate lengths
calculate_lengths()

# fill in feasibility study costs
feasibility_study_costs()
    
# Create the query expression to select all empty segment numbers (aka new line segments, not assigned a number yet)
# Create the search cursor to query all empty segment numbers
fields_to_calculate = [("COST_1A", "1A", cost_trail_1a), ("COST_1B", "1B", cost_trail_1b), ("COST_1C", "1C", cost_trail_1c), ("COST_1X", "1X", cost_trail_1x),
                       ("COST_2A", "2A", cost_trail_2a), ("COST_2B", "2B", cost_trail_2b), ("COST_2C", "2C", cost_trail_2c), ("COST_3A", "3A", cost_trail_3a),
                       ("COST_3B", "3B", cost_trail_3b), ("COST_3C", "3C", cost_trail_3c)]

for field in fields_to_calculate:
 # query_class_field = "CLASS"
 # query_class_value = field[1]
 # query_class_expression = query_class_field + ' = ' + query_class_value
  query_rating_field = "SEG_RATING"
  query_rating_value = field[1]
  query_rating_expression = query_rating_field + " = " + "'" + query_rating_value + "'"
  calculate_cost_field = field[0]
  cost_per_foot = field[2] 

# define a search for the current CLASS and RATING combination (i.e. Class 1, Rating A. Then perform all
# cost calculations for those settings, then start over with the next settings (i.e. Class 1, Rating B)

# the next line prevents the 'for' from running when there is no selection (aka, the following code exits gracefully when there
# are no results from the search cursor)
  row, cur = None, None
 #line two query on two expressions removed when only using SEG_RATING cur = arcpy.UpdateCursor(feature_class, query_class_expression + ' AND ' + query_rating_expression)
  cur = arcpy.UpdateCursor(feature_class, query_rating_expression)

# Iterate through the rows in the cursor
  for row in cur:
    # Trail Segment Cost
    # remove following 4 lines to take feas study calc out of the main script since they will not have a rating
   # if row.isNull("Feasibility_Study_") == 0:
   #   cost = row.Feasibility_Study_
   #   row.setValue(calculate_cost_field, cost)
   # else:
    cost = row.Feet * cost_per_foot
    row.setValue(calculate_cost_field, round(cost))
    # Bridge
    try:
      total_cost_bridge = 0
      if row.BRIDGE == "A":
        total_cost_bridge = row.BRIDGE_LENGTH * cost_bridge_a
        row.setValue("COST_BRIDGE_A", round(total_cost_bridge))
      if row.BRIDGE == "B":
        total_cost_bridge = row.BRIDGE_LENGTH * cost_bridge_b
        row.setValue("COST_BRIDGE_B", round(total_cost_bridge))
    except:
      arcpy.AddMessage("********** SEE BRIDGE ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Bridge data. Please check to make sure whereever there is a bridge rating that there is also a bridge length.")
    # Boardwalk
    try:
      total_cost_boardwalk = 0
      if row.isNull("BOARDWALK_LENGTH") == 0:
        total_cost_boardwalk = row.BOARDWALK_LENGTH * cost_boardwalk_a
        row.setValue("COST_BOARDWALK_A", round(total_cost_boardwalk))
    except:
      arcpy.AddMessage("********** SEE BOARDWALK ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the BOARDWALK data. Please review attribute data")
    # Fence Barrier
    try:
      total_cost_fence_barrier = 0
      if row.FENCE_BARRIER == "A":
        total_cost_fence_barrier = row.FENCE_BARRIER_LENGTH * cost_fence_a
        row.setValue("COST_FENCE_A", total_cost_fence_barrier)
      if row.FENCE_BARRIER == "B":
        total_cost_fence_barrier = row.FENCE_BARRIER_LENGTH * cost_fence_b
        row.setValue("COST_FENCE_B", round(total_cost_fence_barrier))
      if row.FENCE_BARRIER == "C":
        total_cost_fence_barrier = row.FENCE_BARRIER_LENGTH * cost_fence_c
        row.setValue("COST_FENCE_C", round(total_cost_fence_barrier))
      if row.FENCE_BARRIER == "D":
        total_cost_fence_barrier = row.FENCE_BARRIER_LENGTH * cost_fence_d
        row.setValue("COST_FENCE_D", round(total_cost_fence_barrier))
    except:
      arcpy.AddMessage("********** SEE FENCE/BARRIER ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Fence Barrier data. Please check to make sure wherever there is a fence/barrier rating (A, B, C, or D) that there is also a fence/barrier length.")
    # Trail Furnishing
    try:
      total_cost_trail_furnishing = 0
      if row.TRAIL_FURNISHING == "Yes":
        current_trail_segment_cost = row.getValue(calculate_cost_field)
        total_cost_trail_furnishing = current_trail_segment_cost * cost_trail_furnishing
        row.setValue("COST_TRAIL_FURNISHING", round(total_cost_trail_furnishing))
    except:
      arcpy.AddMessage("********** SEE TRAIL FURNISHING ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was a Trail Furnishing error. Let Tim know if this happens.")
    # Environmental Planning Permitting Costs - calls out to function add_coststo do all the adding and
    # pass back total value into setValue code below and multiply by the env/plan/perm cost percentage variable
    try:
      if row.ENV_PLAN_PERMIT == "A":
        row.setValue("COST_ENV_PLAN_PERMIT_A", (round(add_costs() * cost_environmental_plan_a)))
      if row.ENV_PLAN_PERMIT == "B":
        row.setValue("COST_ENV_PLAN_PERMIT_B", (round(add_costs() * cost_environmental_plan_b)))
      if row.ENV_PLAN_PERMIT == "C":
        row.setValue("COST_ENV_PLAN_PERMIT_C", (round(add_costs() * cost_environmental_plan_c)))
    except:
      arcpy.AddMessage("********** SEE ENVIRONMENTAL PLANNING PERMITTING ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Environmental, Planning, and Permitting data.")

    # Design Costs - calls out to function add_costs to do all the adding and
    # pass back total value into setValue code below and multiply by the design cost percentage variable
    try:
      row.setValue("DESIGN_COST", (round(add_costs() * cost_design)))
    except:
      arcpy.AddMessage("********** SEE DESIGN ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Design data.")
    # Construction Costs - calls out to function add_costs to do all the adding and
    # pass back total value into setValue code below
    try:
      row.setValue("CONSTRUCTION_COST", round(add_costs()))
    except:
      arcpy.AddMessage("********** SEE CONSTRUCTION COST ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Construction Cost.")
    # Total Costs - calls out to function add_total_costs to do all the adding and
    # pass back total value into setValue code below
    try:
      row.setValue("TOTAL_COST", add_total_costs())
    except:
      arcpy.AddMessage("********** SEE CONSTRUCTION COST ERROR ON LINE BELOW **********")
      arcpy.AddMessage("There was an error while processing the Construction Cost.")
                       
    cur.updateRow(row)
  del row, cur
