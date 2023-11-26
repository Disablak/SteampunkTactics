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
