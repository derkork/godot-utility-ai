@tool
class_name InfluenceSource2D
extends Node2D


## The maximum range of influence this source has. 
## Note that higher ranges may incur higher processing costs, so try to keep this as low as possible.
@export var max_range:float = 100

## The falloff curve of the influence over the maximum range.
@export var falloff:CurveFunction

## If set to true, all influence maps will ignore this influence source.
@export var ignore:bool = false


## Calculates the influence that this source has at the given position normalized to a value 
## between 0 and 1
func get_influence_at(target_position:Vector2) -> float:
	
	# TODO: calculating the distance is potentially expensive
	var distance = target_position.distance_to(global_position)
	if distance > max_range:
		return 0 
		
	return falloff.sample(distance / max_range)


## Calculates the gradient (slope) of the influence at the given position
func get_influence_gradient_at(target_position:Vector2) -> Vector2:
	
	var distance = target_position.distance_to(global_position)
	# we can skip a few calculations if we are out of range, we just return a zero vector
	# which means that this influence source will not contribute to the gradient
	if distance > max_range:
		return Vector2.ZERO

	# The function we use for calculating the influence is
	# f(x,y) = falloff.sample(sqrt((x-pos.x)^2 + (y-pos.y)^2) / max_range)
	# For keeping the math simple, we will use the following variables:
	# distance = sqrt((x-pos.x)^2 + (y-pos.y)^2)
	# So our function becomes:
	# f(x,y) = falloff.sample(distance / max_range)
	
	# We now need the partial derivatives of this function with respect to x and y
	# df/dx = (x-pos.x) * falloff.sample_derivative(distance / max_range) / (max_range * distance)
	# df/dy = (y-pos.y) * falloff.sample_derivative(distance / max_range) / (max_range * distance)

	# the terms only differ in the x and y components, so we can simplify the calculation
	var offset = target_position - global_position
	var static_part = falloff.sample_derivative(distance / max_range) / (max_range * distance)

	# so we can now calculate the gradient
	return Vector2(
		offset.x * static_part,
		offset.y * static_part
	)
