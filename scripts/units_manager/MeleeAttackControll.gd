class_name MelleeAttackControll
extends Node2D


@export var effect_manager: EffectManager
@export var mini_game: MiniGame

var _cur_unit: Unit
var _enemy_unit: Unit


func _ready() -> void:
	mini_game.on_triggered.connect(_on_trigger_mini_game)


func try_attack_mini_game(from: Unit, to: Unit):
	_cur_unit = from
	_enemy_unit = to

	if can_attack(from, to):
		mini_game.start()
		mini_game.position = from.origin_pos + Vector2(-16, -30)


func try_attack_(from: Unit, to: Unit):
	if can_attack(from, to):
		attack(from, to)


func get_price_attack(unit: Unit) -> int:
	var melle_weapon: MelleWeaponData = unit.unit_data.cur_weapon as MelleWeaponData
	return melle_weapon.melle_weapon_settings.use_price


func can_attack(from: Unit, to: Unit) -> bool:
	if not from or not to:
		return false

	if from.unit_object.is_tween_running:
		return false

	if not from.unit_data.cur_weapon is MelleWeaponData:
		return false

	var melle_weapon: MelleWeaponData = from.unit_data.cur_weapon as MelleWeaponData
	var distance: int = from.unit_object.position.distance_to(to.unit_object.position)

	if distance > melle_weapon.melle_weapon_settings.max_distance:
		return false

	if not TurnManager.can_spend_time_points(melle_weapon.melle_weapon_settings.use_price):
		return false

	return true


func attack(from: Unit, to: Unit, crit: bool = false):
	var melle_weapon: MelleWeaponData = from.unit_data.cur_weapon as MelleWeaponData
	var direction: Vector2 = (to.unit_object.position - from.unit_object.position).normalized()

	TurnManager.spend_time_points(melle_weapon.melle_weapon_settings.use_price)

	await from.unit_object.play_kick_anim(direction)

	var damage := melle_weapon.melle_weapon_settings.damage * 2 if crit else melle_weapon.melle_weapon_settings.damage
	to.unit_object.comp_health.set_damage(damage, from.id)


func _on_trigger_mini_game(success: bool):
	attack(_cur_unit, _enemy_unit, success)
	if success:
		print("crit!")
