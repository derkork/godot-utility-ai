@tool
class_name CustomExpression
extends BaseExpression

## The expression to be used.
var expression:String = ""

var _parsed:Expression = null:
	get:
		if _parsed == null:
			_parsed = Expression.new()	
			var result = _parsed.parse(expression)
			if result != OK:
				push_error("Expression cannot be parsed. Reason: ",  _parsed.get_error_text())
				_parsed = null	
		return _parsed
		
		
func evaluate(base_instance:Node, default:Variant ) -> Variant:
	var parsed_expression = _parsed
	if not is_instance_valid(parsed_expression):
		return default
		
	var result = parsed_expression.execute([], base_instance, true)
	if not parsed_expression.has_execute_failed():
		return result
	
	push_error("Execution of expression failed. Reason: ", parsed_expression.get_error_text())
	return default
	
	
func _get_property_list():
	var properties = []

	properties.append({
		"name": "expression",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_EXPRESSION
	})
	
	return properties
