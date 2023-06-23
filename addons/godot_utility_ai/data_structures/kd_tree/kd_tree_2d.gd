## A two dimensional KD-Tree
class_name KDTree2D

## The root of the tree
var _root:KDTreeNode2D

## The current amount of entries in this tree.
var _size:int


## Clears the tree and fills it with the given entries.
func fill(entries:Array[KDTreeEntry2D]):
	_root = _fill(entries, 0)
	_size = entries.size()


## Returns current amount of entries in this tre
func size() -> int:
	return _size

	
## Finds all entries that are within the given distance from the origin
## point. The order of the elements inside the returned array is not 
## specified.
func find(origin:Vector2, distance:float) -> Array[KDTreeEntry2D]:
	var result:Array[KDTreeEntry2D] = [] 
	if _root == null:
		return result
			
	_find(_root, origin, distance * distance, result)
	return result

	
## Partitions the given entries based on the level and returns the root node of the 
## resulting KD-subtree.
func _fill(entries:Array[KDTreeEntry2D], level:int) -> KDTreeNode2D:
	# If there is nothing in the array, we're done and we won't have a node at all.
	if entries.is_empty():
		return null
		
	# if the array just has one entry, this is the node
	if entries.size() == 1:
		return KDTreeNode2D.new(entries[0], level)
	
	# sort all elements using the appropriate partition function and then take the median element
	entries.sort_custom(func(a:KDTreeEntry2D, b:KDTreeEntry2D): return _get_position(b.position, level) > _get_position(a.position, level))

	# get median index and element	
	var median_index:int = entries.size() / 2
	var median_entry := entries[median_index]
	
	# build the result
	var result = KDTreeNode2D.new(median_entry, level)

	# do we have a left side?
	if median_index > 0: 
		# recurse
		result.left_child = _fill(entries.slice(0, median_index), level+1)
	
	# do we have a right side?
	if median_index + 1 < entries.size():
		result.right_child = _fill(entries.slice(median_index+1, entries.size()), level+1)
		
	return result


## Returns the relevant coordinate for the given level
func _get_position(position:Vector2, level:int) -> float:
	if level % 2 == 0:
		return position.x
	else:
		return position.y

	
## Finds all nodes in the given subtree that are within the given squared distances of the origin
## and adds them to the result array.
func _find(node:KDTreeNode2D, origin:Vector2, distance_squared:float, result:Array[KDTreeEntry2D]):
	# if the current node is inside range, add it
	var distance =  node.position.distance_squared_to(origin)
	if distance <= distance_squared:
		result.append(node.entry)

	# if the node is a leaf, we are done here
	if node.is_leaf:
		return
		
	# we need to check if the circle defined by the search radius would clip across the splitting
	# line indicated by the current node. since this is a circle we can just check if its radius is
	# greate than the horizontal/vertical distance of the origin to the current node. if it is greater
	# then the circle does not clip the splitting line, otherwise it does.
	var node_pos = _get_position(node.position, node.level)
	var origin_pos = _get_position(origin, node.level)
	
	var intersects = abs(node_pos - origin_pos) ** 2 < distance_squared
	
	# We also check if the position of the origin is left or right of the current split line
	var is_left = origin_pos <= node_pos
	
	# if we have a left child and the origin is left or the circle intersects, search the left subtree
	if node.left_child != null and (is_left or intersects):
		_find(node.left_child, origin, distance_squared, result)
	
	# and if we have a right child and the origin is not left or the circle intersects search the right subtree
	if node.right_child != null and ((not is_left) or intersects):
		_find(node.right_child, origin, distance_squared, result)
	
