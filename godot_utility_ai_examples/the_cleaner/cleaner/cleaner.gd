extends CharacterBody2D

## The visibility radius of the cleaner.
@export var visibility_radius:float = 100


@onready var _navigation_agent:NavigationAgent2D = $NavigationAgent2D

var _is_on_ladder := 0

func _walk_towards_target(delta:float):
	var target = Blackboard.retrieve_for(self, "destination")
	print("TARGET ", target)
	
	if target == null:
		return
		
	_navigation_agent.target_position = target
	var next_position = _navigation_agent.get_next_path_position()
	
	velocity = (next_position - global_position).normalized() * 100
	
	# no gravity on ladder
	if not is_on_floor() and _is_on_ladder <= 0:
		velocity.y += 100

	print(velocity)
	
	move_and_slide()
	
	if _navigation_agent.is_navigation_finished():
		Blackboard.remove_for(self, "destination")	


func _is_ladder_tile(tilemap:TileMap, body_rid:RID) -> bool:
	var coords := tilemap.get_coords_for_body_rid(body_rid)
	var result = false
	for layer in tilemap.get_layers_count():
		var data := tilemap.get_cell_tile_data(layer, coords)
		if not data is TileData:
			continue
			
		result = result or data.get_custom_data_by_layer_id(0) # ladder layer
		
	return result

func _on_terrain_detector_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not body is TileMap:
		return # not interesting
		
	if _is_ladder_tile(body, body_rid):
		_is_on_ladder += 1

	print(_is_on_ladder)



func _on_terrain_detector_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if not body is TileMap:
		return # not interesting
		
	if _is_ladder_tile(body, body_rid):
		_is_on_ladder -= 1

	print(_is_on_ladder)
