extends MeshInstance2D

## Path to the map to debug. Will search for children until it finds an InfluenceMap2D
@export_node_path("InfluenceSource2D") var map:NodePath

## The color to draw the map in.
@export var color:Color = Color.CORNFLOWER_BLUE

## The rect onto which we draw the shader
@onready var _rect:MeshInstance2D = self


## The map we debug
var _map:InfluenceMap2D = null

## The current screen center in world space
var _screen_center:Vector2
## The radius of an outcircle of the screen in world size
var _screen_outcircle_radius:float

## Get the map from the node path
func _ready():
	_map = _find_map(get_node_or_null(map))
	if not is_instance_valid(_map):
		printerr("No valid map found. Debugger will show nothing.")
		return

	_map.refreshed.connect(_on_map_refreshed)
	_on_map_refreshed()

	mesh = ImmediateMesh.new()
	material.set_shader_parameter("base_color", color)


func _find_map(node:Node):
	if not is_instance_valid(node):
		return null

	if node is InfluenceMap2D:
		return node
	else:
		for child in node.get_children():
			var map = _find_map(child)
			if is_instance_valid(map):
				return map

	return null

func _process(delta):
	if not visible:
		return
		
	# this rect needs to always be the size of the viewport and it needs to
	# move with any camera2d or other magic that might be going on

	# first determine viewport size
	var viewport_size = get_viewport().size

	# get a transform that can convert from canvas space to world space
	var inverse_canvas_transform = get_viewport().canvas_transform.affine_inverse()

	# now determine the world space point of all 4 corners of the viewport
	var viewport_top_left = inverse_canvas_transform * Vector2(0, 0)
	var viewport_top_right = inverse_canvas_transform * Vector2(viewport_size.x, 0)
	var viewport_bottom_left = inverse_canvas_transform * Vector2(0, viewport_size.y)
	var viewport_bottom_right = inverse_canvas_transform *  Vector2(viewport_size.x, viewport_size.y)

	# take note of the current screen center in world space for querying the influence map
	_screen_center = inverse_canvas_transform * Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
	_screen_outcircle_radius = _screen_center.distance_to(viewport_top_left)

	# and update our mesh
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, material)

	# we need two triangles, first is top_right, bottom_right, top_left
	mesh.surface_add_vertex_2d(viewport_top_right)
	mesh.surface_add_vertex_2d(viewport_bottom_right)
	mesh.surface_add_vertex_2d(viewport_top_left)

	# now the second triangle reuses bottom_right and top_left, so we just need to add bottom_left
	mesh.surface_add_vertex_2d(viewport_bottom_left)

	mesh.surface_end()


func _on_map_refreshed():
	if not visible:
		return
	
	# we support up to 10 sources, if we have more just pick the 10 closest
	var relevant_sources = _map.find_relevant_sources(_screen_center, _screen_outcircle_radius, 10)
	
	# we now build an array of information for the shader to draw
	# for each source we have:
	# - 0 - position.x
	# - 1 - position.y
	# - 2 - radius
	# - 3 - multiplier (1 for additive, -1 for subtractive) 
	# - 4 - falloff-type (0 = polynomial, 1 = logistics, 2 = linear)
	# - 5 - rise
	# - 6 - offset
	# - 7 - exponent
	# - 8 - midpoint

	var data:Array[float] = []
	for source in relevant_sources.keys():
		data.append(source.global_position.x)
		data.append(source.global_position.y)
		data.append(source.max_range)
		data.append(1.0 if relevant_sources[source] else -1.0)
		data.append(float(source.falloff.type))
		data.append(source.falloff.rise)
		data.append(source.falloff.offset)
		data.append(source.falloff.exponent)
		data.append(source.falloff.midpoint)

	material.set_shader_parameter("sources", data)
	material.set_shader_parameter("source_count", relevant_sources.size())
	

