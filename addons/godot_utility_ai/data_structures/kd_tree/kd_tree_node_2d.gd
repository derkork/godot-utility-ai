## A node that is stored inside of KDTree2D
class_name KDTreeNode2D

## The entry represented in this node.
var entry:KDTreeEntry2D

## The position of this node
var position:Vector2

## The level of this node
var level:int

## The left child of this node 
var left_child:KDTreeNode2D

## The right child of this node
var right_child:KDTreeNode2D

## Whether this node is a leaf node
var is_leaf:bool:
	get: return left_child == null and right_child == null


func _init(entry:KDTreeEntry2D, level:int):
	self.entry = entry
	self.level = level
	position = entry.position 



