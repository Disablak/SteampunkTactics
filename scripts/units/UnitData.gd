extends RefCounted

class_name UnitData

var unit_id = -1

var unit_settings: UnitSettings

var cur_health: float
var enemy_data_ai : EnemyDataAI = null
var visibility_data: VisibilityData = VisibilityData.new()


class EnemyDataAI:
	var cur_cover_data = null


func _init(unit_settings: UnitSettings):
	self.unit_settings = unit_settings

	cur_health = unit_settings.max_health

	if unit_settings.is_enemy:
		enemy_data_ai = EnemyDataAI.new()

	unit_settings.init_weapons()


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
	var result = (distance * unit_settings.walk_speed)
	return int(result)
