class_name BlackboardKeyExistsConsideration
extends Consideration

@export var key:StringName = ""
@export var global_blackboard:bool = false
@export_range(0,1) var weight_when_present:float = 1.0
@export_range(0,1) var weight_when_absent:float = 0.0

func consider(entity:Node, context:ConsiderationContext):
	var exists = false
	
	if global_blackboard:
		exists = Blackboard.has(key)
		
	else:
		exists = Blackboard.has_for(entity, key)	
		
	if exists:
		context.record_consideration_result(minimum_rank, weight_when_present)
	else:
		context.record_consideration_result(minimum_rank, weight_when_absent)


