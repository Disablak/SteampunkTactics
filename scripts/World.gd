class_name MyWorld
extends Node2D


@onready var input_system: InputSystem = $InputSystem
@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager

@export var unit_initializator: UnitInitializator
@export var unit_list: UnitList
@export var unit_order: UnitOrder
@export var level_scenes: Array[PackedScene]


func _ready() -> void:
	GlobalMap.world = self
	GlobalMap.draw_debug = $DrawDebug
	GlobalUnits.unit_list = unit_list
	GlobalUnits.unit_order = unit_order


func init(game_progress: GameProgress):
	#var new_level: Level = level_scenes[game_progress.level_id].instantiate() as Level
	#_add_level_to_pathfinding(new_level)

	var units := unit_initializator.create_units(game_progress.units_setting)
	unit_list.add_units(units)
	unit_order.init(units)
	#input_system.init(new_level.map_size)


func _add_level_to_pathfinding(new_level: Level):
	units_manager.pathfinding.add_child(new_level)
	units_manager.pathfinding.move_child(new_level, 0)
