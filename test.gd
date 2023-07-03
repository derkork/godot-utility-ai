extends Node2D

@onready var label:Label = %Label
@onready var enemy_influence:InfluenceMap2D = %Threat


var pos = Vector2(0, 0)
var max_pos = Vector2(0, 0)
var radius = 100	
var points = []
var default_font
func _ready():
	var control = Control.new()
	default_font = control.get_theme_default_font()
	control.queue_free()

func _input(evt:InputEvent):
	if evt is InputEventMouseMotion:
		var world_pos = get_viewport().canvas_transform.affine_inverse() * evt.global_position
		
		var influence = enemy_influence.get_influence_at(world_pos, 1000)
		label.text = "Pos: %s, Influence: %s" % [str(world_pos), str(influence)]
		pos = world_pos
		points = []
		max_pos = enemy_influence.get_influence_maximum_around(world_pos, radius, 20, 50, points )
		queue_redraw()				


func _draw():
	if points.size() > 1:
		draw_polyline(points, Color(1, 1, 0, 1), 2)
		for i in range(points.size()):
			draw_string(default_font, points[i], str(i) )
	draw_circle(max_pos, 5, Color(1,1,1,1))
	draw_circle(pos, radius, Color(1, 0, 0, 0.2))
