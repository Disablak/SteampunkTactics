class_name TweenThroughPoints
extends RefCounted


signal on_reach_point
signal on_finished_tween
signal on_started_tween_to_point(node: Node2D, point: Vector2)

var tween_move: Tween


func tween_through_points(call_create_tween: Callable, node: Node2D, points: PackedVector2Array, speed: float):
	var cur_target_id = 0

	for point in points:
		if cur_target_id == points.size() - 1:
			on_finished_tween.emit()
			return

		var start_point := points[cur_target_id]
		var finish_point := points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / speed

		on_started_tween_to_point.emit(node, finish_point)

		tween_move = call_create_tween.call()
		tween_move.tween_property(
			node,
			"position",
			finish_point,
			time_move
		).from(start_point)

		cur_target_id += 1

		await tween_move.finished
		on_reach_point.emit()


func is_running() -> bool:
	return tween_move and tween_move.is_valid() and tween_move.is_running()
