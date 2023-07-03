class_name MyWorld
extends Node2D


@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager
@onready var input_system: InputSystem = $InputSystem

@export var level_scenes: Array[PackedScene]


func _ready() -> void:
	GlobalMap.world = self
	GlobalMap.draw_debug = $DrawDebug


func init(game_progress: GameProgress):
	var new_level = level_scenes[game_progress.level_id].instantiate() as Level
	units_manager.pathfinding.add_child(new_level)
	units_manager.pathfinding.move_child(new_level, 0)

	units_manager.init(game_progress.units_setting)
	input_system.init(new_level.map_size)

