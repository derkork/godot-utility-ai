extends Node

@onready var label:Label = %Label
@onready var enemy_influence:InfluenceMap2D = %EnemyInfluence



func _input(evt:InputEvent):
	if evt is InputEventMouseMotion:
		var world_pos = evt.position * get_viewport().canvas_transform 
		
		var influence = enemy_influence.get_influence_at(world_pos, 1000)
		label.text = "Pos: %s, Influence: %s" % [str(world_pos), str(influence)]
				
