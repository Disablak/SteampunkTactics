class_name MelleeAttackControll
extends Node2D


@export var effect_manager: EffectManager


func try_attack(from: Unit, to: Unit):
	if can_attack(from, to):
		attack(from, to)


func get_price_attack(unit: Unit) -> int:
	var melle_weapon: MelleWeaponData = unit.unit_data.cur_weapon as MelleWeaponData
	return melle_weapon.melle_weapon_settings.use_price


func can_attack(from: Unit, to: Unit) -> bool:
	if not from or not to:
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


func attack(from: Unit, to: Unit):
	var melle_weapon: MelleWeaponData = from.unit_data.cur_weapon as MelleWeaponData
	var direction: Vector2 = (to.unit_object.position - from.unit_object.position).normalized()

	TurnManager.spend_time_points(melle_weapon.melle_weapon_settings.use_price)

	await from.unit_object.play_kick_anim(direction)
	to.unit_data.set_damage(melle_weapon.melle_weapon_settings.damage, from.id)

	if to.unit_data.is_dead:
		effect_manager.death_effect(to.unit_object.position - Vector2(10, 10), to.unit_object.main_sprite.texture.region)
		to.unit_object.queue_free()
