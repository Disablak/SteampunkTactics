class_name GrenadeEffect
extends RefCounted


signal _on_grenade_reach_last_point()

var _grenade_scene: PackedScene
var _fire_effect_scene: PackedScene
var _root_node: Node2D
var _callback_create_tween: Callable


func _init(callback_create_tween: Callable, grenade_scene: PackedScene, fire_effect_scene: PackedScene, root_node: Node2D) -> void:
	_callback_create_tween = callback_create_tween
	_grenade_scene = grenade_scene
	_fire_effect_scene = fire_effect_scene
	_root_node = root_node


func play(cells: Array[CellInfo], curve_points: PackedVector2Array):
	var granede_instance: Node2D = _grenade_scene.instantiate()
	_root_node.add_child(granede_instance)

	_move_obj_to_points(granede_instance, curve_points, 200)
	await _on_grenade_reach_last_point

	granede_instance.queue_free()

	for cell_info in cells:
		if (not cell_info.is_ground and not cell_info.cell_obj) or (cell_info.cell_obj and cell_info.cell_obj.cell_type == CellObject.CellType.OBSTACLE):
			continue

		var new_fire: Node2D = _fire_effect_scene.instantiate()
		_root_node.add_child(new_fire)

		new_fire.position = Globals.convert_to_cell_pos(cell_info.grid_pos) + Globals.CELL_OFFSET

		var tween: Tween = _callback_create_tween.call()
		tween.tween_property(
			new_fire, "scale",
			Vector2.ZERO, 1.0
		)
		tween.tween_callback(Callable(new_fire, "queue_free"))


func _move_obj_to_points(object: Node2D, points: Array[Vector2], speed: int):
	var tween_move: Tween
	var cur_target_id := 0

	for point in points:
		if cur_target_id == points.size() - 1:
			_on_grenade_reach_last_point.emit()
			return

		var start_point = points[cur_target_id]
		var finish_point = points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / speed

		tween_move = _callback_create_tween.call()
		tween_move.tween_property(
			object,
			"position",
			finish_point,
			time_move
		).from(start_point)

		cur_target_id += 1

		await tween_move.finished
