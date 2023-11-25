class_name TweenThroughPoints
extends RefCounted


signal on_reach_point
signal on_finished_tween


func tween_through_points(call_create_tween: Callable, node: Node2D, points: PackedVector2Array, speed: float):
	var tween_move: Tween
	var cur_target_id = 0

	for point in points:
		if cur_target_id == points.size() - 1:
			on_finished_tween.emit()
			return

		var start_point := points[cur_target_id]
		var finish_point := points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / speed

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
