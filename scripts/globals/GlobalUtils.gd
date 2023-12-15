extends Node


func screen_pos_to_world_pos(screen_pos: Vector2) -> Vector2:
	var camera2d: Camera2D = get_viewport().get_camera_2d()
	var world_pos = screen_pos / camera2d.zoom + camera2d.position
	return world_pos


func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var maps = NavigationServer2D.get_maps()
	var map0 = maps[0]
	var formatted_pos_from = NavigationServer2D.map_get_closest_point(map0, from)
	var formatted_pos_to = NavigationServer2D.map_get_closest_point(map0, to)
	var path = NavigationServer2D.map_get_path(map0, formatted_pos_from, formatted_pos_to, true)

	return path


static func get_total_distance(points: PackedVector2Array) -> float:
	if points.size() <= 1:
		return 0.0

	var distance = 0.0
	var start: Vector2 = points[0]

	for i in range(1, points.size()):
		var end = points[i]
		distance += start.distance_to(end)
		start = points[i]

	return distance


func is_point_inside_nav_polygon(point: Vector2) -> bool:
	var maps = NavigationServer2D.get_maps()
	var map0 = maps[0]
	var formatted_point := NavigationServer2D.map_get_closest_point(map0, point)
	var distance: float = formatted_point.distance_to(point)
	return distance < 2


func get_dir_from_units(from_id: int, to_id: int):
	var from: UnitObject = GlobalUnits.unit_list.get_unit(from_id).unit_object
	var to: UnitObject = GlobalUnits.unit_list.get_unit(to_id).unit_object

	return (to.position - from.position).normalized()


func cut_path(path: PackedVector2Array, size: float) -> PackedVector2Array:
	var result: PackedVector2Array
	var size_available: float = size

	result.append(path[0])

	for i in path.size():
		if i + 1 >= path.size():
			break

		var distance: float = path[i].distance_to(path[i + 1])
		if distance <= size_available:
			size_available -= distance
			result.append(path[i + 1])
		else:
			var dir = (path[i + 1] - path[i]).normalized()
			var end_pos = path[i] + (dir * size_available)
			result.append(end_pos)
			break

	return result


func get_circle_points(center_pos: Vector2, radius: float, segment_count: int) -> Array[Vector2]:
	var result: Array[Vector2]
	for i in segment_count:
		var rad = deg_to_rad(i * 360 / segment_count)
		result.append(center_pos + Vector2(radius * cos(rad), radius * sin(rad)))

	return result


