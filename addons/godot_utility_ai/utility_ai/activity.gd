## An activity is something an AI-controlled unit can choose to do. 
## Activities are picked based on considerations. Considerations 
## modify the rank and weight of an activity. Based on rank and 
## weight an activity is picked and executed. Only one activity is
## active at a time. 
class_name Activity
extends Node

## Emitted when this activity has been picked.
signal activity_begins()

## Emitted when another activity has been picked and this activity should end.
signal activity_ends()

## The considerations we use for this activity
var _considerations:Array[Consideration] = []
## The consideration context we use for this activity
var _consideration_context:ConsiderationContext

func _init():
	_consideration_context = ConsiderationContext.new(self)

func _ready():
	# Get all children which are considerations and store them for later use.
	for child in get_children():
		if child is Consideration:
			_considerations.append(child)
	
## Considers the utility of this activity and stores the result in the given
## decision context.
func consider(entity:Node, context:DecisionContext):
	for consideration in _considerations:
		consideration.consider(entity, _consideration_context)
		# if after this consideration we already know we won't take this
		# action, we can break out early
		if _consideration_context.will_not_be_taken:
			break	
	
	
