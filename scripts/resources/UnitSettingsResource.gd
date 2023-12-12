class_name UnitSettingsResource
extends Resource


@export var unit_name: String = "Unit"
@export var is_enemy: bool = true
@export var max_health: float = 20.0
@export var walk_speed: int = 10 # price for 1 metr
@export var initiative: int = 10
@export var range_of_view: int = 5

@export var equips: Array[EquipBase]
@export var abilities: Array[AbilitySettings]


func get_object() -> UnitSetting:
	var unit_setting = UnitSetting.new()

	unit_setting.unit_name = unit_name
	unit_setting.is_enemy = is_enemy
	unit_setting.max_health = max_health
	unit_setting.walk_speed = walk_speed
	unit_setting.initiative = initiative
	unit_setting.range_of_view = range_of_view

	unit_setting.equips = equips
	unit_setting.abilities = abilities

	return unit_setting
