## Entry inside of a KDTree2D
class_name KDTreeEntry2D

## The position of the entry.
var position:Vector2 = Vector2.ZERO

## A dictionary with additional data for this entry.
var data:Dictionary = {}


func _init(position:Vector2):
	self.position = position
