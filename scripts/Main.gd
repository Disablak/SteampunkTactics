extends Node3D


@onready var world = $World
@onready var gui = $GUI as GUI

@export var main_hero_start_setting: UnitSettingsResource
@export var level_id := 0


func _ready() -> void:
	var game_progress: GameProgress = _get_progress()
	gui.init_unit_setup(func(): start_battle(game_progress))


func start_battle(game_progress: GameProgress):
	world.init(game_progress)
	gui.init()


func _get_progress() -> GameProgress:
	var progress = GameProgress.new()
	progress.units_setting.assign([main_hero_start_setting.get_object()])
	progress.level_id = level_id

	return progress
