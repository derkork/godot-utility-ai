class_name Consideration
extends Node

## The minimum rank that the owning activity should get if this consideration
## contributes a weight. 
@export var minimum_rank:int = 1

func consider(entity:Node, context:ConsiderationContext):
	push_warning("The Consideration base class does not do anything, please use a subtype.")
