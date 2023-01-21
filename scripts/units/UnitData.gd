extends RefCounted

class_name UnitData

var unit_id = -1
var is_enemy: bool

var unit_settings: UnitSettings
var ai_settings: AiSettings
var visibility_data: VisibilityData = VisibilityData.new()

var cur_health: float


func _init(unit_settings: UnitSettings, ai_settings: AiSettings):
	self.unit_settings = unit_settings
	self.ai_settings = ai_settings

	is_enemy = ai_settings != null
	cur_health = unit_settings.max_health

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
