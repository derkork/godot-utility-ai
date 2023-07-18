extends Node2D

## The visibility radius of the cleaner.
@export var visibility_radius:float = 100


@onready var navigation_agent:NavigationAgent2D

func _walk_towards_target(delta:float):
	pass 
