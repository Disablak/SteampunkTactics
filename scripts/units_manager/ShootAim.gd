class_name ShootAim
extends Node2D


const DISTANCE_TO_APPLY_OFFSET = 100


@export var line2d_manager: Line2dManager
@export var all_covers: AllCovers
@export var raycaster: Raycaster

var _cur_unit: Unit
var _ranged_weapon: RangedWeaponData
var _aim_enabled: bool = false
var _aim_time: float = 0.0
var _aim_vector: Vector2
var _aim_dir: Vector2
var _aim_input_mouse: bool = true

var _cur_unit_pos: Vector2:
	get: return _cur_unit.unit_object.position

var aim_vector: Vector2:
	get: return _aim_vector

var aim_enabled: bool:
	get: return _aim_enabled


func enable_aim(unit: Unit):
	_cur_unit = unit
	_ranged_weapon = _cur_unit.unit_data.cur_weapon as RangedWeaponData
	_aim_enabled = true
	_aim_time = randf_range(0.0, 1.0)

	all_covers.try_to_disable_cover_collision(unit)


func disable_aim():
	_aim_enabled = false
	_aim_input_mouse = true

	GlobalMap.draw_debug.clear_lines("shoot line")
	GlobalMap.draw_debug.clear_lines("min_max_dir")
	line2d_manager.clear_ray()
	line2d_manager.set_shoot_raycast_pos(Vector2.ZERO, Vector2.ZERO)

	all_covers.enable_all_covers_collision()


func set_aim_dir(aim_dir: Vector2):
	_aim_dir = aim_dir
	_aim_input_mouse = false


func _process(delta: float) -> void:
	if not _aim_enabled:
		return

	_calc_and_draw_aim_direction(_get_aim_dir(), delta)


func _calc_and_draw_aim_direction(aim_dir: Vector2, delta: float):
	var vector_to_aim_dir_100px: Vector2 = _cur_unit_pos + aim_dir * DISTANCE_TO_APPLY_OFFSET
	var perpendecular_vector_to_aim_dir: Vector2 = _get_perpendecular_vector_to_mouse_dir(aim_dir)

	var min_dir: Vector2 = vector_to_aim_dir_100px - perpendecular_vector_to_aim_dir
	var max_dir: Vector2 = vector_to_aim_dir_100px + perpendecular_vector_to_aim_dir
	#_draw_debug(min_dir, max_dir)

	var lerp_time = _get_lerp_time(delta)
	var lerp_from_min_to_max: Vector2 = lerp(min_dir, max_dir, lerp_time)
	var dir_to_lerpred_value: Vector2 = (lerp_from_min_to_max - _cur_unit_pos).normalized()

	_aim_vector = dir_to_lerpred_value * _ranged_weapon.ranged_weapon_settings.max_range

	var ray_end_pos: Vector2 = raycaster.make_ray_and_get_collision_point(
		_cur_unit_pos,
		_cur_unit_pos + _aim_vector,
		ShootControll.RAY_UNIT_LAYER,
		_cur_unit.unit_object.get_this_exclude_rid()
	)

	line2d_manager.set_shoot_raycast_pos(_cur_unit_pos, ray_end_pos)


func _get_aim_dir() -> Vector2:
	if _aim_input_mouse:
		return _get_dir_to_mouse()
	else:
		return _aim_dir


func _get_dir_to_mouse() -> Vector2:
	var formatted_mouse_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(get_viewport().get_mouse_position())
	var dir_to_mouse: Vector2 = (formatted_mouse_pos - _cur_unit_pos).normalized()

	return dir_to_mouse


func _get_perpendecular_vector_to_mouse_dir(dir_to_mouse: Vector2) -> Vector2:
	var degree = Vector2.RIGHT.angle_to(dir_to_mouse) + PI / 2
	var vec_perpen = Vector2.from_angle(degree) * _ranged_weapon.ranged_weapon_settings.aim_offset

	return vec_perpen


func _draw_debug(min_dir, max_dir):
	GlobalMap.draw_debug.clear_lines("min_max_dir")
	GlobalMap.draw_debug.add_line([_cur_unit_pos, min_dir], "min_max_dir")
	GlobalMap.draw_debug.add_line([_cur_unit_pos, max_dir], "min_max_dir")


func _get_lerp_time(delta: float) -> float:
	_aim_time += delta * _ranged_weapon.ranged_weapon_settings.aim_speed
	var pong = pingpong(_aim_time, 1.0)
	var ease_pong = ease(pong, -2)

	return ease_pong

