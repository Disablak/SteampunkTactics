class_name RangedWeaponSettings
extends AbilitySettings


@export var max_ammo := 1
@export var reload_price := 30
@export var aim_speed := 1.0
@export var aim_offset := 3


func _to_string() -> String:
	return super._to_string() + "Ammo {0}\nReload Price {1}".format([max_ammo, reload_price])
