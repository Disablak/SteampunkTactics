extends Node

@export var player: Node2D
@export var nav_region: NavRegion
@export var line2d_manager: Line2dManager

var tween_through_points: TweenThroughPoints = TweenThroughPoints.new()


func move_object_to_pos(object: Node2D, pos: Vector2):
	var nav_obstacle: NavObstacle = object.find_child("NavObstacle")

	nav_obstacle.disable_obstacle()
	await nav_region.bake_finished
	await get_tree().process_frame

	var path := _find_path(object.position + Vector2(5, 5), pos)
	_draw_path(path)

	tween_through_points.tween_through_points(get_tree().create_tween, object, path, 100)
	await tween_through_points.on_finished_tween

	nav_obstacle.enable_obstacle()


func _disable_object_obstalce(object: Node2D):
	var nav_obstacle: NavObstacle = object.find_child("NavObstacle")
	nav_obstacle.disable_obstacle()


func _find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var maps = NavigationServer2D.get_maps()
	var map0 = maps[0]
	var formatted_pos_from = NavigationServer2D.map_get_closest_point(map0, from)
	var formatted_pos_to = NavigationServer2D.map_get_closest_point(map0, to)
	var path = NavigationServer2D.map_get_path(map0, formatted_pos_from, formatted_pos_to, true)

	return path


func _draw_path(path: PackedVector2Array):
	var path_array: Array[Vector2]
	path_array.assign(Array(path))
	line2d_manager.clear_path()
	line2d_manager.draw_path_without_offset(path_array, false)


func _on_objects_selector_on_click_on_object(click_pos: Vector2, objects: Array[Node]) -> void:
	move_object_to_pos(player, click_pos)
