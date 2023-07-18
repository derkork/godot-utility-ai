class_name NodeExpression
extends BaseExpression

@export var node:NodePath

func evaluate(base_instance:Node, default:Variant) -> Variant:
	var result = base_instance.get_node_or_null(node)

	if is_instance_valid(result):
		return result
	return default
