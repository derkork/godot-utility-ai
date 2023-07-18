@tool
## Base expression type. Don't use this, rather use a subclasss of this.
class_name BaseExpression
extends Resource 


# Evaluates the expression and returns its value. If the expression is invalid or execution fails
# returns the given default value.
func evaluate(base_instance:Node, default:Variant) -> Variant:
	return default

	
