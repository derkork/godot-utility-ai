@tool
## A float value
class_name FloatExpression
extends BaseExpression

@export var value:float

func evaluate(base_instance:Node, default:Variant) -> Variant:
	return value
	
