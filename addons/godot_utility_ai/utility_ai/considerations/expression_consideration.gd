@tool
## A consideration that evaluates an expression. 
class_name ExpressionConsideration
extends Consideration

## The expression to evaluate. Should return a value between 0 and 1.
@export var expression:BaseExpression


## A curve to be applied on the value returned by the expression. Optional,
## if not given then the value of the expression will be used as weight for 
## this consideration.
@export var curve:CurveFunction


func _ready():
	if not is_instance_valid(expression):
		push_error("Expression of consideration ", name , " is not set. This consideration will be ignored.")

func consider(entity:Node, context:ConsiderationContext):
	# if the expression is not valid, do nothing.
	if not is_instance_valid(expression):
		return
	
	var result = expression.evaluate(entity, 0.0)
		
	if not result is float:
		push_warning("Expression did not return a float, but ", result, ". Consideration ", name, " will not be taken.")
		return 
		
	if result < 0 or result > 1:
		push_warning("Expression returned a value outside of the allowed range of 0 to 1 (", result, ")",  \
			  "Consideration " , name , " will use value ", clamp(result, 0, 1.0), " instead.")
	
	# if we have a curve, run the result through it
	var weight = 0
	if is_instance_valid(curve):
		weight = curve.sample(result)
	# otherwise just clamp it to ensure it is in the allowed range.
	else:
		weight = clamp(result, 0, 1.0)

	context.record_consideration_result(minimum_rank, weight)
