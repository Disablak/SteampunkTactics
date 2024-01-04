extends Node3D


@onready var world: MyWorld = $World
@onready var gui: GUI = $GUI as GUI

@export var main_hero_start_setting: UnitSettingsResource
@export var level_id := 0


func _ready() -> void:
	var game_progress: GameProgress = _get_progress()
	start_battle(game_progress)
	#gui.init_unit_setup(game_progress, func(): start_battle(game_progress))


func start_battle(game_progress: GameProgress):
	world.init(game_progress)
	gui.init()


func _get_progress() -> GameProgress:
	var progress = GameProgress.new()
	progress.units_setting.assign([main_hero_start_setting.get_object()])
	progress.level_id = level_id

	return progress

