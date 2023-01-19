class_name GranadeData
extends WeaponBaseData


@export var throw_distance: int = 2
@export var max_count: int = 1

var cur_count: int


func init_weapon():
	super.init_weapon()
	_set_weapon_ammo(max_count)


func is_enough_grenades(count = 1) -> bool:
	return cur_count >= count


func spend_grenade(count = 1):
	_set_weapon_ammo(cur_count - count)


func _set_weapon_ammo(value):
	cur_count = value
	GlobalBus.on_unit_updated_weapon.emit(GlobalUnits.cur_unit_id, self)
