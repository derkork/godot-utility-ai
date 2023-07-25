class_name InfluenceMapStrengthIndicator2D
extends Label

@export_node_path("InfluenceMap2D") var influence_map:NodePath

var _map:InfluenceMap2D

func _ready():
	_map = get_node_or_null(influence_map)
	
func _input(event):
	if not is_instance_valid(_map):
		return
	
	if event is InputEventMouseMotion:
		text = str(_map.get_influence_at(event.position))
