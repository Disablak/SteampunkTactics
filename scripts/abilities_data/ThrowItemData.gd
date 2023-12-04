class_name ThrowItemData
extends WeaponData

var throw_item_settings: ThrowItemSettings:
	get: return settings as ThrowItemSettings

var cur_count: int


func init_weapon():
	super.init_weapon()
	_set_weapon_ammo(throw_item_settings.max_count)


func is_enough_grenades(count = 1) -> bool:
	return cur_count >= count


func spend_grenade(count = 1):
	_set_weapon_ammo(cur_count - count)


func _set_weapon_ammo(value):
	cur_count = value
	GlobalBus.on_unit_updated_weapon.emit(GlobalUnits.unit_list.get_cur_unit_id(), self)
