class_name MyWorld
extends Node2D


@onready var input_system: InputSystem = $InputSystem

@export var nav_region: NavRegion

@export_group("Unit Components")
@export var unit_initializator: UnitInitializator
@export var unit_list: UnitList
@export var unit_order: UnitOrder
@export var unit_controll: UnitControll

@export_group("Levels")
@export var level_scenes: Array[PackedScene]

@export_group("Test")
@export var is_playground: bool = false
@export var playground_scene: PackedScene


func _ready() -> void:
	GlobalMap.world = self
	GlobalMap.draw_debug = $DrawDebug
	GlobalMap.effect_manager = $EffectManager
	GlobalUnits.unit_list = unit_list
	GlobalUnits.unit_order = unit_order
	GlobalUnits.unit_control = unit_controll


func init(game_progress: GameProgress):
	_spawn_level(game_progress.level_id)
	nav_region.init()

	var units := unit_initializator.create_units(game_progress.units_setting)
	unit_list.add_units(units)
	unit_order.init(units)


func _spawn_level(level_id: int):
	var new_level = (playground_scene if is_playground else level_scenes[level_id]).instantiate()
	add_child(new_level)
	move_child(new_level, 0)

