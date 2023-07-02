extends Node3D


@onready var world = $World
@onready var gui = $GUI as GUI

@export var main_hero_start_setting: UnitSettingsResource
@export var level_id := 0


func _ready() -> void:
	var start_unit_settings = _get_settings()
	gui.init_unit_setup(func(): start_battle(level_id, start_unit_settings))


func start_battle(id, unit_settings: Array[UnitSetting]):
	world.init(id, unit_settings)
	gui.init()


func _get_settings() -> Array[UnitSetting]:
	return [main_hero_start_setting.get_object()]
