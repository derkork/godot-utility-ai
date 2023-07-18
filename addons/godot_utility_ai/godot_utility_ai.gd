@tool
extends EditorPlugin


var _curve_function_editor:EditorInspectorPlugin
var _edited_object

func _enter_tree():
	_curve_function_editor = preload("editor/curve_function_editor/curve_function_editor.gd").new()
	get_editor_interface().get_selection().selection_changed.connect(update_overlays)
	add_inspector_plugin(_curve_function_editor)


func _exit_tree():
	remove_inspector_plugin(_curve_function_editor)


func _handles(object):
	return object is InfluenceSource2D
	
func _edit(object):
	_edited_object = object
	
func _forward_canvas_draw_over_viewport(viewport_control):
	if _edited_object is InfluenceSource2D and not _edited_object.ignore:
		var transform = _edited_object.get_viewport_transform() * _edited_object.get_canvas_transform()
		# calculate center in viewport space
		var center =  transform * _edited_object.position
		# calculate radius in viewport space
		var radius = ((transform * (_edited_object.position + Vector2(_edited_object.max_range, 0))) - center).length()
		viewport_control.draw_circle(center, radius, Color(1, 0.0784314, 0.576471, 0.2))
