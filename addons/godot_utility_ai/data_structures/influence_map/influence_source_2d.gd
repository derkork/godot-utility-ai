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
