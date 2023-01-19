class_name WeaponData
extends WeaponBaseData


@export var accuracy: Curve
@export var ammo := 1
@export var reload_price := 30


var cur_weapon_ammo: int


func init_weapon():
	super.init_weapon()
	reload_weapon()


func is_enough_ammo(count = 1) -> bool:
	return cur_weapon_ammo >= count


func reload_weapon():
	_set_weapon_ammo(ammo)


func spend_weapon_ammo(count = 1):
	_set_weapon_ammo(cur_weapon_ammo - count)


func _set_weapon_ammo(value):
	cur_weapon_ammo = value
	GlobalBus.on_unit_updated_weapon.emit(GlobalUnits.cur_unit_id, self)
