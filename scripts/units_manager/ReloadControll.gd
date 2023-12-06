class_name ReloadControll
extends Node2D


func try_to_reload(unit: Unit):
	if not _can_reload(unit):
		return

	var ranged_weapon: RangedWeaponData = unit.unit_data.cur_weapon as RangedWeaponData
	ranged_weapon.reload_weapon()
	TurnManager.spend_time_points(ranged_weapon.ranged_weapon_settings.reload_price)


func _can_reload(unit: Unit):
	if not unit.unit_data.cur_weapon is RangedWeaponData:
		return false

	var ranged_weapon := (unit.unit_data.cur_weapon as RangedWeaponData)
	if TurnManager.cur_time_points < ranged_weapon.ranged_weapon_settings.reload_price:
		return false

	return true
