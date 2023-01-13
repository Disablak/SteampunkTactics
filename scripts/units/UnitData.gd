extends RefCounted

class_name UnitData

var unit_id = -1

var unit_settings: UnitSettings
var weapon: WeaponData
var granade: GranadeData

var cur_health: float
var cur_weapon_ammo: int
var enemy_data_ai : EnemyDataAI = null
var visibility_data: VisibilityData = VisibilityData.new()



class EnemyDataAI:
	var cur_cover_data = null


func _init(unit_settings: UnitSettings):
	self.unit_settings = unit_settings
	self.weapon = unit_settings.weapon
	self.granade = unit_settings.granade

	cur_health = unit_settings.max_health
	cur_weapon_ammo = weapon.ammo

	if unit_settings.is_enemy:
		enemy_data_ai = EnemyDataAI.new()


func set_unit_id(id):
	self.unit_id = id


func set_damage(value: float, attacker_unit_id: int):
	if cur_health <= 0:
		print("unit {0} is already dead".format([unit_id]))
		return

	cur_health -= value
	GlobalBus.on_unit_change_health.emit(unit_id)

	if cur_health <= 0:
		GlobalBus.on_unit_died.emit(unit_id, attacker_unit_id)
		print_debug("unit_died ", unit_id)


func get_move_price(distance: float) -> int:
	var result = (distance * unit_settings.walk_speed) / Globals.CELL_SIZE
	return int(result)


func is_enough_ammo(count = 1) -> bool:
	return cur_weapon_ammo >= count


func reload_weapon():
	_set_weapon_ammo(weapon.ammo)


func spend_weapon_ammo(count = 1):
	_set_weapon_ammo(cur_weapon_ammo - count)


func _set_weapon_ammo(value):
	cur_weapon_ammo = value
	GlobalBus.on_unit_changed_ammo.emit(unit_id, cur_weapon_ammo, weapon.ammo)
