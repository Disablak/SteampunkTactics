class_name ObjectMover
extends Node

@export var nav_region: NavRegion

var tween_through_points: TweenThroughPoints = TweenThroughPoints.new()


func move_object_to_pos(object: Node2D, pos: Vector2):
	var nav_obstacle: NavObstacle = object.find_child("NavObstacle")

	nav_obstacle.disable_obstacle()
	await nav_region.bake_finished
	await get_tree().process_frame
	await get_tree().process_frame

	var path := GlobalUtils.find_path(object.position, pos)

	tween_through_points.tween_through_points(get_tree().create_tween, object, path, 100)
	await tween_through_points.on_finished_tween

	nav_obstacle.enable_obstacle()


func is_object_moving() -> bool:
	return tween_through_points.is_running()
