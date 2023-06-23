@tool	
## A curve modeling function. Such functions are defined in a range of 0 to 1 and return
## values between 0 and 1.
class_name CurveFunction
extends Resource

# Emitted when the curve parameters have changed. 
signal curve_changed

enum CurveFunctionType {
	LINEAR = 0,
	POLYNOMIAL = 1,
	LOGICSTICS = 2,
}

var _function:Callable = _undefined

## The type of the function.
@export var type:CurveFunctionType = CurveFunctionType.LINEAR:
	set(value):
		type = value
		_refresh()

## The rise of the function. 
@export var rise:float = 1:
	set(value):
		rise = value
		_refresh()
	

## The offset of the function.
@export var offset:float = 0:
	set(value):
		offset = value
		_refresh()
		
		
## The exponent of the function.
@export var exponent:float = 1:
	set(value):
		exponent = value
		_refresh()

## The modpoint of the function.
@export var midpoint:float = 1:
	set(value):
		midpoint = value
		_refresh()


func _refresh():
	match type:
		CurveFunctionType.LINEAR:
			_function = _linear
		CurveFunctionType.LOGICSTICS:
			_function = _logistic
		CurveFunctionType.POLYNOMIAL:
			_function = _polynomial

	curve_changed.emit()
		
## Returns a value at the given input index.
func sample(input:float) -> float:
	var x = clamp(input, 0.0, 1.0)
	return clamp(_function.call(x), 0.0, 1.0)

## A function that is used when nothing is initialized yet. Returns 0 for all inputs.
func _undefined(x:float) -> float:
	return 0

## A a linear function.
func _linear(x:float) -> float:
	return rise * (x - midpoint) + offset

## A logistic function.	
func _logistic(x:float) -> float:
	return rise * (1 /(1 + exp(-exponent * (x - midpoint)))) + offset

## A polynomial function.
func _polynomial(x:float) -> float:
	return rise * ((x - midpoint) ** exponent) + offset
