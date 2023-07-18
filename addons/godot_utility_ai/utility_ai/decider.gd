## The decider is the root node of the AI system. You attach this to an AI controlled
## unit. Below the decider you can add activities and considerations.
class_name Decider
extends Node

## A node path to the entity which owns this decider. This is used for 
## accessing the blackboard of this entity. If unset, this decider will
## be used for accessing the blackboard.
@export var owning_entity:NodePath 

var _decision_context:DecisionContext = DecisionContext.new()


var _activities:Array[Activity] = []


func _ready():
	# Prepare the activities
	for child in get_children():
		if child is Activity:
			_activities.append(child)

func decide():
	var entity = get_node_or_null(owning_entity)
	if not is_instance_valid(entity):
		entity = self
		
	# Consider all activities so we can find out which one we use.
	for activity in _activities:
		activity.consider(entity, _decision_context)
		
	var winner = _decision_context.pick_winner_or_null()
		
	if is_instance_valid(winner):
		winner.start_or_continue(entity)
		
	
	
		
