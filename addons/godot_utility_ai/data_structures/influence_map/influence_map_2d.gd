@tool
class_name InfluenceMap2D
extends Node

## A signal that is emitted whenever the influence map is refreshed.
signal refreshed

## The interval at which the influence map refreshes in seconds. Values should be between 0.5 and 1.5 depending
## on your needs. Lower intervals provide more accurate data at higher CPU cost, higher intervals
## provide less accurate data at lower CPU cost.
@export var refresh_interval:float = 0.5

## Only influence sources that are in the given groups will be added to this
## influence map. If this is empty the influence map will not 
@export var source_groups:Array[String] = [] 


## The KDTree holding the influence sources.
var _tree:KDTree2D = KDTree2D.new()

## The maximum range of any known influence source. We can use this to
## limit queries to an area of interest.
var _max_source_range:float = 0

func _ready():
	# don't do anything in the editor
	if not Engine.is_editor_hint():
		_refresh()
	
## Refreshes the influence map. New sources will be detected, old sources will be discarded.
func _refresh():
	# we use a dictionary here to avoid duplicates
	var entries = {}
	_max_source_range = 0
	
	# find all unique influence sources in the given groups
	for group in source_groups:
		var nodes = get_tree().get_nodes_in_group(group)
		for node in nodes:
			if node is InfluenceSource2D and not node.ignore:
				entries[node] = node
				_max_source_range = max(_max_source_range, node.max_range)
				
				
	# create tree entries and add them to the tree
	var tree_entries:Array[KDTreeEntry2D] = []
	for entry in entries.keys():
		var tree_entry := KDTreeEntry2D.new(entry.global_position)
		tree_entry.data["source"] = entry
		tree_entries.append(tree_entry)
		
	_tree.fill(tree_entries)
		
	
	# schedule a refresh
	get_tree().create_timer(refresh_interval).timeout.connect(_refresh)

	# emit the refreshed signal
	refreshed.emit()
		

## Gets a normalized influence value (0 to 1) at the given position taking into
## account influence sources within the given radius.
func get_influence_at(position:Vector2, max_radius:float = 100) -> float:
	
	# first determine the search radius and get all influence sources within
	# that radius that are potentially relevant
	var total_radius = max_radius + _max_source_range
	var entries = _tree.find(position, total_radius)
	
	# Then sum up the influence of all sources near the given position
	var total := 0.0
	for entry in entries:
		var source = entry.data["source"]
		var influence = source.get_influence_at(position)
		total += influence
		
	# and normalize it
	return clamp(total, 0.0, 1.0)

## Calculates the gradient of the influence map at the given position using the given set of influence sources.
func _get_influence_gradient_at(position:Vector2, entries:Array[InfluenceSource2D]) -> Vector2:

	# We calculate the gradient by calculating the derivative of the influence function
	# at the given position. We need to calculate the derivative of the sum of all influence
	# functions, which is the sum of all derivatives. So we iterate over all sources and
	# add their derivative to the total derivative. The derivative of a source is the
	# gradient of the influence function at the given position.

	var total_gradient = Vector2.ZERO
	for entry in entries:
		var gradient = entry.get_influence_gradient_at(position)
		total_gradient += gradient

	return total_gradient

## Calculates the influence at the given position using the given set of influence sources.
func _get_influence_at(position:Vector2, entries:Array[InfluenceSource2D]) -> float:
	var total := 0.0
	for entry in entries:
		var influence = entry.get_influence_at(position)
		total += influence
		
	return clamp(total, 0.0, 1.0)


## Returns the position of the maximum influence within the given radius of the given position. Note that this
## is a heuristic and not guaranteed to return the actual maximum influence position. You can tune the accuracy
## and speed of this function using the step_limit and scale parameters. The step_limit determines how many
## steps are taken to find the maximum influence position. The scale determines the size of the steps. 
## Increasing the amount of steps may increase the accuracy of the result but also increases the computation time.
## The step size is in world unit and determines the size of the steps. Bigger step sizes can help to avoid 
## finding a local maximum instead of the global maximum but they can also cause the function to miss the maximum
## entirely. So you may need to experiment with these parameters to find the right balance between accuracy and speed.
func get_influence_maximum_around(position:Vector2, radius:float, step_limit:int = 5, scale:float = 100, points = null) -> Vector2:
	return _get_influence_extremum(position, radius, step_limit, scale, true, points)


## Returns the position of minimum or maximum influence within the given radius of the given position.
func _get_influence_extremum(position:Vector2, radius:float, step_limit:int, scale:float, maximum:bool, points) -> Vector2:

	# find all sources that could be relevant for this search
	var max_radius = radius + _max_source_range
	var sources = find_relevant_sources(position, radius) # find_relevant_sources automatically adds _max_source_range to the radius

	# if no sources are nearby, we cannot find anything and will just return the start position
	if sources.size() == 0:
		return position

	# we start at the position
	var search_point := position
	
	# calculate the starting influence
	var extremum = _get_influence_at(search_point, sources)
	# get the gradient at the current search point
	var gradient = _get_influence_gradient_at(search_point, sources).normalized()
	
	# if the gradient is zero, try a point closer towards the
	# one of the influence sources
	var idx = 0
	while gradient.length_squared() < 0.00001:
		if idx >= sources.size() or idx > step_limit:
			# no more sources to try, give up
			return position
		search_point =  position + (sources[idx].global_position - position).normalized() * radius
		gradient = _get_influence_gradient_at(search_point, sources).normalized()
		extremum = _get_influence_at(search_point, sources)
		idx += 1
		
	# if we used steps to find a better starting point, these count as well so we start
	# at idx.
	for step in range(idx, step_limit):
		# add the points for debugging
		if points != null:
			points.append(search_point)
			
		# if we should find the maximum and have found a value of 1.0 we can stop
		if maximum and extremum >= 1.0:
			return search_point
			
		# similarly if we should find the minimum and have found a value of 0.0 we can stop
		elif not maximum and extremum <= 0.0:
			return search_point

		
		var new_search_point:Vector2
		# if we search the maximum we move in the direction of the gradient
		if maximum:
			new_search_point = search_point + (gradient * scale)
		# otherwise we move in the opposite direction
		else:
			new_search_point = search_point - (gradient * scale)
			

		# if the new search point is outside the radius we stop and return the current one
		var new_distance = (new_search_point - position).length()
		if new_distance > radius:
			return search_point
			

		# calculate the influence at the new search point
		var new_extremum = _get_influence_at(new_search_point, sources)
		# check if we overshot, then we stop and return the current search point
		if (maximum and new_extremum < extremum) or (not maximum and new_extremum > extremum):
			return search_point
			
			
		# calculate the new gradient at the search point
		gradient = _get_influence_gradient_at(new_search_point, sources).normalized()	

		search_point = new_search_point
		extremum = new_extremum

	return search_point


## Finds all influence sources that are potentially relevant to the given position within the given radius.
func find_relevant_sources(position:Vector2, max_radius:float = 100) -> Array[InfluenceSource2D]:
	
	# first determine the search radius and get all influence sources within
	# that radius that are potentially relevant
	var total_radius = max_radius + _max_source_range
	var entries = _tree.find(position, total_radius)
	
	# Then build an array
	var sources:Array[InfluenceSource2D] = []
	for entry in entries:
		var source = entry.data["source"]
		sources.append(source)
		
	return sources
