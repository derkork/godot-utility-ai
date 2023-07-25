
## A consideration that will pick a target location from an [InfluenceMap2D] and
## store it in the local blackboard under a given name. If no suitable spot can
## be found, the current position will be returned.
class_name InfluenceMapLocationPicker2D
extends Consideration

enum TargetExtremum {
	## The picker will pick a target location where influence is lowest.
	LOWEST,
	## The picker will pick a target location where influence is highest.
	HIGHEST
}

## The influence map which should be used. Use a NodeExpression to refer to a node
## directly or a BlackboardExpression to pick a node from the blackboard.
@export var influence_map:BaseExpression = NodeExpression.new()

## Whether the picker should pick a location with the lowest or highest influence.
@export var influence:TargetExtremum = TargetExtremum.HIGHEST

## The radius within which the picker should look for a suitable spot.
@export var radius:BaseExpression = FloatExpression.new()

## The position where to look. If empty, will try to use the owning entities
## global position instead.
@export var position:BaseExpression

## A curve to be applied depending on how far the picked spot is,
## from the current position (where 0 is the current position and 1 is the radius). 
## If empty, a linear curve will be used where positions further away from the 
## position yield higher multipliers.
@export var curve:CurveFunction

## The blackboard key under which the found position should be stored.
@export var blackboard_key:StringName = ""

func consider(entity:Node, context:ConsiderationContext):
	if not is_instance_valid(influence_map):
		push_error("The `influence_map` property of consideration ", name , " is required but not set. ", \
				"The consideration will be ignored.")
		return
	
	if not is_instance_valid(radius):
		push_error("The `radius` property of consideration ", name , " is required but not set. ", \
				"The consideration will be ignored.")
		return
	
	if not is_instance_valid(position) and not entity is Node2D:
		push_error("Cannot determine a position. Please either specify the position in the `position` property ", \
			"or ensure that the owning entity is a Node2D. Consideration ", name , " will be ignored.")
		return
	
	# Prerequisites checked.
	
	var the_map = influence_map.evaluate(entity, null)
	if not (the_map is InfluenceMap2D):
		push_error("The expression for the influence map returned ", the_map, \
			". Consideration ", name, " requires an InfluenceMap2D. Please check the expression. ", \
			"Consideration will be ignored.")
		return
	
	var final_position = Vector2.ZERO
	if is_instance_valid(position):
		var position_from_expression = position.evaluate(entity, Vector2.ZERO)
		if not position_from_expression is Vector2:
			push_warning("The `position` expression returned ", position_from_expression, " which is not a Vector2. ", \
				"Consideration ", name,  " will be ignored.")
			return

		final_position = position_from_expression
	else:
		final_position = entity.global_position
		
	
	var final_radius = radius.evaluate(entity, 0.0)
	if not final_radius is float:
		push_warning("The radius` expression returned ", final_radius, " which is not a float. ", \
				"Consideration ", name,  " will be ignored.")
		return				
		
		
	var point = final_position
	if influence == TargetExtremum.HIGHEST:
		point = the_map.get_influence_maximum_around(final_position, final_radius)
	else:
		point = the_map.get_influence_minimum_around(final_position, final_radius)
	
	var multiplier = point.distance_to(final_position) / final_radius
	if is_instance_valid(curve):
		multiplier = curve.sample(multiplier)
		
		
	# TODO: this is not working when we have multiple activities. At the end
	# we only want blackboard entries materialized when the activity is actually
	# picked
	

	context.record_consideration_result(minimum_rank, multiplier, func(): 
		if not blackboard_key.is_empty():
			Blackboard.store_for(entity, blackboard_key, point)
	)
		
