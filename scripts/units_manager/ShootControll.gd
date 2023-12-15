class_name ShootControll
extends Node


@export var line2d_manager: Line2dManager
@export var effect_manager: EffectManager
@export var raycaster: Raycaster
@export var shoot_aim: ShootAim

var _cur_unit: Unit


func enable_aim(unit: Unit):
	_cur_unit = unit
	shoot_aim.enable_aim(unit)


func disable_aim():
	shoot_aim.disable_aim()


func set_aim_dir_and_disable_mouse(aim_dir: Vector2):
	shoot_aim.set_aim_dir(aim_dir)


func make_shoot():
	_shoot()


func can_shoot(from: Unit) -> bool:
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


func _on_input_system_on_pressed_lmc(mouse_pos: Vector2) -> void:
	if shoot_aim.aim_enabled:
		_shoot()


func _shoot():
	_spend_time_and_ammo()
	disable_aim()

	var shoot_pos: Vector2 = _cur_unit.origin_pos + shoot_aim.aim_vector;
	var ray_result = _raycast_and_get_result(shoot_pos)
	if not ray_result.is_empty():
		shoot_pos = ray_result.position

	effect_manager.shoot_effect.create_bullet_and_tween(create_tween(), _cur_unit.unit_object.position, shoot_pos, func(): _on_bullet_finish_tween(ray_result))


func _on_bullet_finish_tween(ray_result):
	if ray_result.is_empty():
		return

	var hitted_unit: Unit = _get_unit_from_ray_result(ray_result)
	_set_damage_to_enemy(_cur_unit, hitted_unit)
	_if_enemy_died_play_effect(hitted_unit)


func _raycast_and_get_result(shoot_pos: Vector2) -> Dictionary:
	var exclude_rids: Array[RID] = [_cur_unit.unit_object.interactable_stat_body.get_rid()]
	const RAY_UNIT_LAYER := 8
	var ray_result = raycaster.make_ray(_cur_unit.unit_object.position, shoot_pos, RAY_UNIT_LAYER, exclude_rids)

	GlobalMap.draw_debug.clear_lines("shoot line")
	GlobalMap.draw_debug.add_line([_cur_unit.origin_pos, shoot_pos], "shoot line")

	return ray_result


func _get_unit_from_ray_result(ray_result: Dictionary) -> Unit:
	var unit_object: UnitObject = ray_result.collider.get_parent()
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_object.unit_id)
	return unit


func _set_damage_to_enemy(player: Unit, enemy: Unit):
	var ranged_weapon: RangedWeaponData = _cur_unit.unit_data.cur_weapon
	enemy.unit_data.set_damage(ranged_weapon.settings.damage, player.id)


func _if_enemy_died_play_effect(enemy: Unit):
	if enemy.unit_data.is_dead:
		effect_manager.death_effect(enemy.unit_object.position - Vector2(10, 10), enemy.unit_object.main_sprite.texture.region)
		enemy.unit_object.queue_free()


func _spend_time_and_ammo():
	var ranged_weapon: RangedWeaponData = _cur_unit.unit_data.cur_weapon as RangedWeaponData
	TurnManager.spend_time_points(ranged_weapon.ranged_weapon_settings.use_price)
	ranged_weapon.spend_weapon_ammo()

