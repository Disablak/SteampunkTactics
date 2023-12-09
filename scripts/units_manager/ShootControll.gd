class_name ShootControll
extends Node


@export var line2d_manager: Line2dManager
@export var effect_manager: EffectManager
@export var raycaster: Raycaster


var attack_confirmed: bool = false
var unit_attacker: Unit
var aim_time: float = 0.0
var aim_direction: Vector2


func try_to_shoot(from: Unit):
	if not _can_shoot(from):
		return

	unit_attacker = from

	var ranged_weapon: RangedWeaponData = from.unit_data.cur_weapon as RangedWeaponData

	if attack_confirmed:
		TurnManager.spend_time_points(ranged_weapon.ranged_weapon_settings.use_price)
		ranged_weapon.spend_weapon_ammo()
		#_shoot_and_kill(from, to)
		deselect_attack()
	else:
		#select enemy
		#_draw_ray(from, to)
		attack_confirmed = true


func deselect_attack():
	line2d_manager.clear_ray()
	attack_confirmed = false


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


func _shoot_and_kill(player: Unit, enemy: Unit):
	await effect_manager.shoot_effect.create_bullet_and_tween(create_tween(), player.unit_object.position, enemy.unit_object.position)
	_set_damage_to_enemy(player, enemy)


func _set_damage_to_enemy(player: Unit, enemy: Unit):
	enemy.unit_data.set_damage(10, player.id)

	if enemy.unit_data.is_dead:
		effect_manager.death_effect(enemy.unit_object.position - Vector2(10, 10), enemy.unit_object.main_sprite.texture.region)
		enemy.unit_object.queue_free()


func _draw_ray(from: Unit, to: Unit):
	var ray_points: Array[Vector2]
	ray_points.assign([from.unit_object.position, to.unit_object.position])
	line2d_manager.draw_ray(ray_points)


func _shoot(dir: Vector2):
	var shoot_pos: Vector2 = unit_attacker.unit_object.position + dir;
	var exclude_rids: Array[RID] = [unit_attacker.unit_object.interactable_stat_body.get_rid()]
	var ray_result = raycaster.make_ray(unit_attacker.unit_object.position, shoot_pos, 8, exclude_rids)

	GlobalMap.draw_debug.clear_lines("shoot line")
	GlobalMap.draw_debug.add_line([unit_attacker.unit_object.position, shoot_pos], "shoot line")

	if not ray_result.is_empty():
		shoot_pos = ray_result.position

	await effect_manager.shoot_effect.create_bullet_and_tween(create_tween(), unit_attacker.unit_object.position, shoot_pos)
	if not ray_result.is_empty():
		var unit_object: UnitObject = ray_result.collider.get_parent()
		var unit: Unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
		_set_damage_to_enemy(unit_attacker, unit)



func _process(delta: float) -> void:
	if not attack_confirmed or not unit_attacker:
		return

	var formatted_mouse_pos: Vector2 = GlobalUtils.screen_pos_to_world_pos(get_viewport().get_mouse_position())
	var dir: Vector2 = (formatted_mouse_pos - unit_attacker.unit_object.position).normalized()
	var dir_to_50px = unit_attacker.unit_object.position + dir * 50
	var degree = Vector2.RIGHT.angle_to(dir) + PI / 2

	const SIDE_OFFSET_PX = 2
	var vec_perpen = Vector2.from_angle(degree) * SIDE_OFFSET_PX

	var min_dir: Vector2 = dir_to_50px - vec_perpen
	var max_dir: Vector2 = dir_to_50px + vec_perpen

	GlobalMap.draw_debug.clear_lines("min_max_dir")
	GlobalMap.draw_debug.add_line([unit_attacker.unit_object.position, min_dir], "min_max_dir")
	GlobalMap.draw_debug.add_line([unit_attacker.unit_object.position, max_dir], "min_max_dir")

	var speed = 1
	aim_time += delta * speed
	var pong = pingpong(aim_time, 1.0)
	var ease_pong = ease(pong, -2)

	var lerp_from_min_to_max: Vector2 = lerp(min_dir, max_dir, ease_pong)
	var dir_to_lerpred_value: Vector2 = (lerp_from_min_to_max - unit_attacker.unit_object.position).normalized()

	aim_direction = dir_to_lerpred_value * 500

	line2d_manager.set_shoot_raycast_pos(unit_attacker.unit_object.position, unit_attacker.unit_object.position + aim_direction)


func _on_input_system_on_pressed_lmc(mouse_pos: Vector2) -> void:
	_shoot(aim_direction)
