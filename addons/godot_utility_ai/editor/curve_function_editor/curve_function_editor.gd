## An editor for CurveFunction objects
@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is CurveFunction


func _parse_begin(object):
	if not (object is CurveFunction):
		push_error("Object is not a CurveFunction")
		return

	var preview = preload("curve_function_preview.gd").new()
	preview.curve_function = object
	add_custom_control(preview)
