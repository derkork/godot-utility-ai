@tool
extends EditorPlugin


var _curve_function_editor:EditorInspectorPlugin

func _enter_tree():
	_curve_function_editor = preload("editor/curve_function_editor/curve_function_editor.gd").new()
	add_inspector_plugin(_curve_function_editor)


func _exit_tree():
	remove_inspector_plugin(_curve_function_editor)
