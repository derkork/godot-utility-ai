@tool
extends OptionButton


## The curve that is currently being edited.
var curve_function:CurveFunction = null:
	set(value):
		if curve_function != null:
			curve_function.curve_changed.disconnect(_check_preset)

		curve_function = value
		
		if curve_function != null:
			curve_function.curve_changed.connect(_check_preset)
			if item_count > 0:
				_check_preset()
							
## The presets that are available.
var _presets:Dictionary	= {}

## A helper variable to suspend update events while we are applying
## a preset.
var _is_applying: bool = false
	
			
func _init():
	_presets["Linear Rise"] = _make_preset(CurveFunction.CurveFunctionType.LINEAR, 1, 0, 1, 0)
	_presets["Linear Falloff"] = _make_preset(CurveFunction.CurveFunctionType.LINEAR, -1, 1, 1, 0)
	_presets["Quadratic Rise"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, 1, 0, 2, 0)
	_presets["Quadratic Falloff"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, -1, 1, 2, 0)
	_presets["Cubic Rise"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, 1, 0, 3, 0)
	_presets["Cubic Falloff"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, -1, 1, 3, 0)
	_presets["S-Curve"] = _make_preset(CurveFunction.CurveFunctionType.LOGISTICS, 1, 0, 6, 0.5)
	_presets["Inverted S-Curve"] = _make_preset(CurveFunction.CurveFunctionType.LOGISTICS, -1, 1, 6, 0.5)
	_presets["Valley"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, 4, 0, 2, 0.5)
	_presets["Mountain"] = _make_preset(CurveFunction.CurveFunctionType.POLYNOMIAL, -4, 1, 2, 0.5)
	
	
func _ready():
	add_item("Select a preset...")
	for item in _presets.keys():
		add_item(item)
		
	item_selected.connect(_apply_preset)
	_check_preset()
		
	
func _make_preset(type:CurveFunction.CurveFunctionType, \
		rise:float, offset:float, exponent:float, midpoint:float):
	var result := CurveFunction.new()
	result.type = type
	result.rise = rise
	result.offset = offset
	result.exponent = exponent
	result.midpoint = midpoint
	return result

func _apply_preset(idx):
	var text = get_item_text(idx)
	var preset:CurveFunction = _presets[text]
	if not is_instance_valid(preset):
		return
	
	## Avoid checking the preset while we are applying it.
	_is_applying = true
	curve_function.type = preset.type
	curve_function.rise = preset.rise
	curve_function.offset = preset.offset
	curve_function.exponent = preset.exponent
	curve_function.midpoint = preset.midpoint
	_is_applying = false

func _check_preset():
	if _is_applying:
		return

	# Try to find a preset that is the same as the currently
	# set up function. If we find one, select it, otherwise
	# select the item, so the user knows that his function no
	# longer matches a preset.
	var idx = 0
	for item in _presets.keys():
		# the real presets start at 1, so increasing this here is ok
		idx += 1
		var preset:CurveFunction = _presets[item]		
		if preset.type != curve_function.type:
			continue
		if preset.rise != curve_function.rise:
			continue
		if preset.offset != curve_function.offset:
			continue
		if preset.exponent != curve_function.exponent:
			continue
		if preset.midpoint != curve_function.midpoint:
			continue
		# We found a matching item
		select(idx)
		return	
	
	# we found no matching item, select the first index
	select(0)
			
	
	
