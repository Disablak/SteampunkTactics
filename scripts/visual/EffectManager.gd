class_name EffectManager
extends Node2D


@export var bullet_scene: PackedScene
@export var granede_scene: PackedScene
@export var fire_effect_scene: PackedScene

signal on_moved_obj_to_points()

const BULLET_SPEED = 1500
const SHOOT_MISS_POS_LERP = [0.0, 0.1, 0.2, 0.3, 0.7, 0.8, 0.9, 1.0]
const MISSED_BULLET_DISTANCE = 1000
const MISS_MAX_BULLET_OFFSET = 5

var _line2d_manager: Line2dManager


func inject_data(line2d_manager: Line2dManager):
	self._line2d_manager = line2d_manager


func shoot(from: Unit, to: Unit, hit_type: ShootingModule.HitType, cover_pos: Vector2, random_obs: CellObject):
	var from_pos: Vector2 = from.unit_object.position
	var to_pos: Vector2 = to.unit_object.position

	if hit_type == ShootingModule.HitType.HIT_IN_COVER:
		to_pos = cover_pos
	elif hit_type == ShootingModule.HitType.HIT_IN_OBS:
		to_pos = random_obs.position
	elif hit_type == ShootingModule.HitType.MISS:
		to_pos = from_pos + _get_little_wrong_shoot_direction(to_pos - from_pos)

	await GlobalsUi.input_system.camera_controller.center_camera_between_two_units(from, to)

	var points = PackedVector2Array([from_pos, to_pos])
	var line = _line2d_manager.draw_shoot_ray(points)
	await Globals.create_timer_and_get_signal(0.05)

	_line2d_manager.clear_shoot_ray()


func _get_little_wrong_shoot_direction(shoot_vector: Vector2) -> Vector2:
	var dir: Vector2 = shoot_vector.normalized()
	var degree = Vector2.RIGHT.angle_to(dir) + PI / 2
	var vec_perpen = Vector2.from_angle(degree) * MISS_MAX_BULLET_OFFSET

	var random_offset = lerp(-vec_perpen, vec_perpen, SHOOT_MISS_POS_LERP.pick_random())
	var with_big_length: Vector2 = (shoot_vector + random_offset).normalized() * MISSED_BULLET_DISTANCE

	return with_big_length


func granade(cells: Array[CellInfo]):
	var granede_instance: Node2D = granede_scene.instantiate()
	add_child(granede_instance)

	_move_obj_to_points(granede_instance, _line2d_manager.line2d_trajectory.points, 200)
	await on_moved_obj_to_points
	granede_instance.queue_free()

	for cell_info in cells:
		if cell_info.cell_obj == null or cell_info.cell_obj.cell_type != CellObject.CellType.GROUND:
			continue

		var new_fire: Node2D = fire_effect_scene.instantiate()
		add_child(new_fire)

		new_fire.position = Globals.convert_to_cell_pos(cell_info.grid_pos)

		var tween: Tween = create_tween()
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
			on_moved_obj_to_points.emit()
			return

		var start_point = points[cur_target_id]
		var finish_point = points[cur_target_id + 1]
		var time_move = start_point.distance_to(finish_point) / speed

		tween_move = get_tree().create_tween()
		tween_move.tween_property(
			object,
			"position",
			finish_point,
			time_move
		).from(start_point)

		cur_target_id += 1

		await tween_move.finished

