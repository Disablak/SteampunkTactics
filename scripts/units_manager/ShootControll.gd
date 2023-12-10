class_name ShootControll
extends Node


@export var line2d_manager: Line2dManager
@export var effect_manager: EffectManager
@export var raycaster: Raycaster

var _aim_enabled: bool = false
var _cur_unit: Unit
var _aim_time: float = 0.0
var _aim_vector: Vector2
var _cur_unit_pos: Vector2:
	get: return _cur_unit.unit_object.position


func enable_aim(from: Unit):
	if not _can_shoot(from):
		return

	_cur_unit = from
	_aim_enabled = true


func disable_aim():
	_aim_enabled = false

	GlobalMap.draw_debug.clear_lines("shoot line")
	GlobalMap.draw_debug.clear_lines("min_max_dir")
	line2d_manager.clear_ray()
	line2d_manager.set_shoot_raycast_pos(Vector2.ZERO, Vector2.ZERO)


func _can_shoot(from: Unit) -> bool:
	if not from:
		return false

	if not from.unit_data.cur_weapon is RangedWeaponData :
		return false

	var ranged_weapon: RangedWeaponData = from.unit_data.cur_weapon as RangedWeaponData
	if not ranged_weapon.is_enough_ammo():
		return false

	if not TurnManager.can_spend_time_points(ranged_weapon.ranged_weapon_settings.use_price):
		return false

	if effect_manager.shoot_effect.is_tweening():
		return false

	return true


func _process(delta: float) -> void:
	if not _aim_enabled or not _cur_unit:
		return

	_calc_and_draw_aim_direction(delta)


func _on_input_system_on_pressed_lmc(mouse_pos: Vector2) -> void:
	if not _aim_enabled or not _cur_unit:
		return

	_shoot()


func _calc_and_draw_aim_direction(delta: float):
	var dir_to_mouse: Vector2 = _get_dir_to_mouse()
	const DISTANCE_TO_APPLY_OFFSET = 100
	var vector_to_mouse_100px: Vector2 = _cur_unit_pos + dir_to_mouse * DISTANCE_TO_APPLY_OFFSET
	var perpendecular_vector_to_mouse_dir: Vector2 = _get_perpendecular_vector_to_mouse_dir(dir_to_mouse)

	var min_dir: Vector2 = vector_to_mouse_100px - perpendecular_vector_to_mouse_dir
	var max_dir: Vector2 = vector_to_mouse_100px + perpendecular_vector_to_mouse_dir
	_draw_debug(min_dir, max_dir)

	var lerp_time = _get_lerp_time(delta)
	var lerp_from_min_to_max: Vector2 = lerp(min_dir, max_dir, lerp_time)
	var dir_to_lerpred_value: Vector2 = (lerp_from_min_to_max - _cur_unit_pos).normalized()

	const MAX_SHOOT_DISTANCE = 500
	_aim_vector = dir_to_lerpred_value * MAX_SHOOT_DISTANCE

	line2d_manager.set_shoot_raycast_pos(_cur_unit_pos, _cur_unit_pos + _aim_vector)


func _get_dir_to_mouse() -> Vector2:
	var formatted_mouse_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(get_viewport().get_mouse_position())
	var dir_to_mouse: Vector2 = (formatted_mouse_pos - _cur_unit_pos).normalized()

	return dir_to_mouse


func _get_perpendecular_vector_to_mouse_dir(dir_to_mouse: Vector2) -> Vector2:
	var degree = Vector2.RIGHT.angle_to(dir_to_mouse) + PI / 2
	const SIDE_OFFSET_PX = 2 # TODO take from weapon settings
	var vec_perpen = Vector2.from_angle(degree) * SIDE_OFFSET_PX

	return vec_perpen


func _draw_debug(min_dir, max_dir):
	GlobalMap.draw_debug.clear_lines("min_max_dir")
	GlobalMap.draw_debug.add_line([_cur_unit_pos, min_dir], "min_max_dir")
	GlobalMap.draw_debug.add_line([_cur_unit_pos, max_dir], "min_max_dir")


func _get_lerp_time(delta: float) -> float:
	const AIM_SPEED = 1 #TODO get from weapon settings
	_aim_time += delta * AIM_SPEED
	var pong = pingpong(_aim_time, 1.0)
	var ease_pong = ease(pong, -2)

	return ease_pong


func _shoot():
	_spend_time_and_ammo()
	disable_aim()

	var shoot_pos: Vector2 = _cur_unit_pos + _aim_vector;
	var exclude_rids: Array[RID] = [_cur_unit.unit_object.interactable_stat_body.get_rid()]
	const RAY_UNIT_LAYER := 8
	var ray_result = raycaster.make_ray(_cur_unit.unit_object.position, shoot_pos, RAY_UNIT_LAYER, exclude_rids)

	GlobalMap.draw_debug.clear_lines("shoot line")
	GlobalMap.draw_debug.add_line([_cur_unit_pos, shoot_pos], "shoot line")

	if not ray_result.is_empty():
		shoot_pos = ray_result.position

	await effect_manager.shoot_effect.create_bullet_and_tween(create_tween(), _cur_unit.unit_object.position, shoot_pos)
	if ray_result.is_empty():
		return

	var hitted_unit: Unit = _get_unit_from_ray_result(ray_result)
	_set_damage_to_enemy(_cur_unit, hitted_unit)


func _get_unit_from_ray_result(ray_result: Dictionary) -> Unit:
	var unit_object: UnitObject = ray_result.collider.get_parent()
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
	return unit


func _set_damage_to_enemy(player: Unit, enemy: Unit):
	var ranged_weapon: RangedWeaponData = _cur_unit.unit_data.cur_weapon
	enemy.unit_data.set_damage(ranged_weapon.settings.damage, player.id)

	if enemy.unit_data.is_dead:
		effect_manager.death_effect(enemy.unit_object.position - Vector2(10, 10), enemy.unit_object.main_sprite.texture.region)
		enemy.unit_object.queue_free()


func _spend_time_and_ammo():
	var ranged_weapon: RangedWeaponData = _cur_unit.unit_data.cur_weapon as RangedWeaponData
	TurnManager.spend_time_points(ranged_weapon.ranged_weapon_settings.use_price)
	ranged_weapon.spend_weapon_ammo()

