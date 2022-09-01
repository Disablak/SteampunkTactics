extends Reference

class_name UnitData

var unit_id = -1

var cur_health
var max_health

var cur_walk_distance
var max_walk_distance

var weapon: WeaponData
var cur_weapon_ammo: int


func _init(unit_settings: UnitSettings):
	cur_health = unit_settings.max_health
	max_health = unit_settings.max_health
	
	cur_walk_distance = unit_settings.walk_distance
	max_walk_distance = unit_settings.walk_distance
	
	weapon = unit_settings.weapon
	cur_weapon_ammo = weapon.ammo


func set_unit_id(id):
	self.unit_id = id


func set_damage(value, attacker_unit_id):
	if cur_health <= 0:
		print("unit {0} is already dead".format([unit_id]))
		return
	
	cur_health -= value
	GlobalBus.emit_signal(GlobalBus.on_unit_change_health_name, unit_id)
	
	if cur_health <= 0:
		GlobalBus.emit_signal(GlobalBus.on_unit_died_name, unit_id, attacker_unit_id)
		print_debug("unit_died ", unit_id)


func can_move(distance: float) -> bool:
	return cur_walk_distance >= distance


func remove_walk_distance(value):
	if cur_walk_distance <= 0 || value > cur_walk_distance:
		print("unit {0} cant walk".format([unit_id]))
		return
	
	set_walk_distance(cur_walk_distance - value)


func restore_walk_distance():
	set_walk_distance(max_walk_distance)


func set_walk_distance(value):
	var clamped_value = clamp(value, 0.0, max_walk_distance)
	cur_walk_distance = clamped_value
	GlobalBus.emit_signal(GlobalBus.on_unit_changed_walk_distance, unit_id)


func is_enough_ammo(count = 1) -> bool:
	return cur_weapon_ammo >= count


func reload_weapon():
	_set_weapon_ammo(weapon.ammo)


func spend_weapon_ammo(count = 1):
	_set_weapon_ammo(cur_weapon_ammo - count)


func _set_weapon_ammo(value):
	cur_weapon_ammo = value
	GlobalBus.emit_signal(GlobalBus.on_unit_changed_ammo_name, unit_id, cur_weapon_ammo, weapon.ammo)
