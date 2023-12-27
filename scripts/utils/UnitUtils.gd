class_name UnitUtils
extends Node


static func get_weapon_of_type(unit: Unit, weapon_type: WeaponData.WeaponType) -> Array[WeaponData]:
	var all_weapons: Array[WeaponData] = unit.unit_data.all_weapons
	var weapons_of_type: Array[WeaponData] = all_weapons.filter(func(x): return _filter_weapon(x, weapon_type))
	return weapons_of_type


static func _filter_weapon(weapon: WeaponData, weapon_type: WeaponData.WeaponType) -> bool:
	if weapon is RangedWeaponData and weapon_type == WeaponData.WeaponType.RANGE:
		return true
	elif weapon is MelleWeaponData and weapon_type == WeaponData.WeaponType.MALEE:
		return true
	elif weapon is ThrowItemData and weapon_type == WeaponData.WeaponType.GRENADE:
		return true

	return false
