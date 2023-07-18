@tool
## A preview control for the given curve function
extends Control


## The curve that is currently being previewed
var curve_function:CurveFunction = null:
	set(value):
		if curve_function != null:
			curve_function.curve_changed.disconnect(_repaint)

		curve_function = value

		if curve_function != null:
			curve_function.curve_changed.connect(_repaint)

		_repaint()

func _get_minimum_size():
	return Vector2(165, 200)

func _repaint():
	queue_redraw()

func _draw():
	if curve_function == null:
		return

	# draw a coordinate system from 0,0 to 1,1 stretching over the whole control
	var rect = Rect2(Vector2(), get_size())
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + Vector2(rect.size.x, rect.size.y), Color.WHITE)
	draw_line(rect.position, rect.position + Vector2(0, rect.size.y), Color.WHITE)

	# draw some pips indicating 0.5 on the x and y axis
	draw_line(rect.position + Vector2(0, rect.size.y * 0.5), rect.position + Vector2(rect.size.x, rect.size.y * 0.5), Color(1,1,1,0.2))
	draw_line(rect.position + Vector2(rect.size.x * 0.5, 0), rect.position + Vector2(rect.size.x * 0.5, rect.size.y), Color(1,1,1,0.2))

	# draw the curve. we take 100 samples from the curve and draw a line between each sample. We map the available width and height to the range 0..1
	# we collect all points in a Vector2 array and then draw this as a polyline, as this is more efficient than drawing each line individually
	var points = []
	for i in range(100):
		var x = float(i) / 100.0
		var y = curve_function.sample(x)
		points.append(rect.position + Vector2(x * rect.size.x, (1.0 - y) * rect.size.y))

	draw_polyline(points, Color.YELLOW)
