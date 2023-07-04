extends GdUnitTestSuite

var _under_test:KDTree2D

func before_test():
	_under_test = KDTree2D.new()



func test_insert_retrieve():
	# SETUP
	# we create an insert a few nodes
	var nodes:Array[KDTreeEntry2D] = [
		KDTreeEntry2D.new(Vector2(0, 0)),
		KDTreeEntry2D.new(Vector2(100, 100)),
		KDTreeEntry2D.new(Vector2(-100, -100)),
		KDTreeEntry2D.new(Vector2(300, 300)),		
	]

	_under_test.fill(nodes)

	# WHEN
	# i query for nodes in a circle around the center
	var result := _under_test.find(Vector2(0, 0), 100)


	# THEN
	# I get the center node back
	assert_vector(result[0].position).is_equal(nodes[0].position)
	
	# WHEN 
	# i query for the nodes in a circle around 150, 150
	result = _under_test.find(Vector2(150, 150), 100)

	# THEN
	# i get the the lower right node back
	assert_vector(result[0].position).is_equal(nodes[1].position)

	# WHEN
	# i query for the nodes in a circle around -150, -150
	result = _under_test.find(Vector2(-150, -150), 100)

	# THEN
	# i get the the upper left node back
	assert_vector(result[0].position).is_equal(nodes[2].position)

	# WHEN
	# i query for the node in the lowest right position
	result = _under_test.find(Vector2(350, 350), 100)
	
	# THEN
	# i get the lowest right node back
	assert_vector(result[0].position).is_equal(nodes[3].position)
