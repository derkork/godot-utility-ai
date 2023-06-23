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
		var tree_entry := KDTreeEntry2D.new(entry.position)
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