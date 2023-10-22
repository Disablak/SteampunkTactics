extends NavigationRegion2D

var new_navigation_polygon: NavigationPolygon = get_navigation_polygon()

func _ready():
	parse_2d_collisionshapes(self)

	new_navigation_polygon.make_polygons_from_outlines()
	set_navigation_polygon(new_navigation_polygon)

	await get_tree().create_timer(2).timeout

	print("removed")
	new_navigation_polygon.remove_outline(1)
	new_navigation_polygon.make_polygons_from_outlines()


func parse_2d_collisionshapes(root_node: Node2D):
	for node in root_node.get_children():

		if node.get_child_count() > 0:
			parse_2d_collisionshapes(node)

		if node is CollisionPolygon2D:

			var collisionpolygon_transform: Transform2D = node.get_global_transform()
			var collisionpolygon: PackedVector2Array = node.polygon

			var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon

			new_navigation_polygon.add_outline(new_collision_outline)
