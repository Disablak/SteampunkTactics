class_name NavRegion
extends NavigationRegion2D


@export var polygon2d: Polygon2D
@export var polygon2d_circle: Polygon2D
@export var polygon2d_intersection: Polygon2D


func _ready() -> void:
	_subscribe_on_nav_obstacle()
	_bake()

	_test()


func _subscribe_on_nav_obstacle():
	var all_nav_obstacles = get_tree().get_nodes_in_group(NavObstacle.OBSTACLE_GROUP_NAME)
	for nav_obstacle in all_nav_obstacles:
		nav_obstacle.on_obstacle_change.connect(_on_obstacle_change)


func _on_obstacle_change():
	_bake()


func _bake():
	bake_navigation_polygon(false)


func _test():
	await get_tree().process_frame

	polygon2d.polygon = navigation_polygon.get_vertices()
	for i in navigation_polygon.get_polygon_count():
		polygon2d.polygons.append(navigation_polygon.get_polygon(i))

	var circle_vertices: PackedVector2Array
	var count_segments: int = 20
	var radius: int = 100
	var unit_pos: Vector2 = GlobalUnits.unit_list.get_cur_unit().unit_object.position
	for i in count_segments:
		var rad = deg_to_rad(i * 360 / count_segments)
		circle_vertices.append(unit_pos + Vector2(radius * cos(rad), radius * sin(rad)))

	polygon2d_circle.polygon = circle_vertices
	var intersected_polygons = []

	for idx: PackedInt32Array in polygon2d.polygons:
		var micro_polygon: PackedVector2Array = get_polygon_by_idx(idx, polygon2d.polygon)
		var intersection = Geometry2D.intersect_polygons(polygon2d_circle.polygon, micro_polygon)
		if intersection.size() != 0:
			intersected_polygons.append_array(intersection)

	var all_vertices: PackedVector2Array
	for polygon: PackedVector2Array in intersected_polygons:
		all_vertices.append_array(polygon)


	polygon2d_intersection.polygon = all_vertices


	var first_idx: int = 0
	for polygon: PackedVector2Array in intersected_polygons:
		polygon2d_intersection.polygons.append(get_idx_by_polygon(first_idx, polygon))
		first_idx = first_idx + polygon.size()



func get_idx_by_polygon(start_idx: int, polygon: PackedVector2Array) -> PackedInt32Array:
	var result: PackedInt32Array
	for i in polygon.size():
		result.append(start_idx + i)

	return result


func get_polygon_by_idx(idx: PackedInt32Array, polygon: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array
	for id in idx:
		result.append(polygon[id])

	return result

