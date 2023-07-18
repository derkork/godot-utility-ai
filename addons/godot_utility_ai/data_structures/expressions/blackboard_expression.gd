class_name BlackboardExpression
extends BaseExpression

## The blackboard key which should be extracted.
@export var key:StringName

## If true, the value will be extracted from the global blackboard, otherwise from the local blackboard.
@export var global_blackboard:bool

func evaluate(base_instance:Node, default:Variant) -> Variant:
	if global_blackboard:
		return Blackboard.retrieve(key, default)
	
	return Blackboard.retrieve_for(base_instance, key, default)

