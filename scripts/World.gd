class_name MyWorld
extends Node2D



@export var nav_region: NavRegion
@export var object_selector: ObjectSelector
@export var all_covers: AllCovers

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

var _game_progress: GameProgress
var _cur_level: Node2D


func _ready() -> void:
	GlobalMap.world = self
	GlobalMap.draw_debug = $DrawDebug
	GlobalMap.effect_manager = $EffectManager
	GlobalUnits.unit_list = unit_list
	GlobalUnits.unit_order = unit_order
	GlobalUnits.unit_control = unit_controll


func init(game_progress: GameProgress):
	_game_progress = game_progress
	_change_level(game_progress)


func _change_level(game_progress: GameProgress):
	if not _is_level_exist(game_progress.level_id):
		print("levels ended")
		return

	_remove_previous_level()
	_spawn_level(game_progress.level_id)

	nav_region.init()
	var units := unit_initializator.create_units(game_progress.units_setting)
	unit_list.init(units)
	unit_order.init(units)
	object_selector.init()
	all_covers.init()

	GlobalBus.on_changed_level.emit(game_progress.level_id)


func _remove_previous_level():
	if _cur_level:
		_cur_level.free()

	nav_region.deinit()
	unit_list.deinit()
	unit_order.deinit()
	object_selector.deinit()
	all_covers.deinit()
	unit_controll.deinit()


func _spawn_level(level_id: int):
	_cur_level = (playground_scene if is_playground else level_scenes[level_id]).instantiate()
	add_child(_cur_level)
	move_child(_cur_level, 0)


func _is_level_exist(level_id: int):
	return level_id >= 0 and level_id < level_scenes.size()


func _on_battle_states_on_changed_battle_state(battle_states: BattleStates) -> void:
	if battle_states.is_game_over:
		if battle_states.cur_state == BattleStates.BattleState.MY_WIN:
			_game_progress.level_id += 1

		await get_tree().create_timer(1.0).timeout

		_change_level(_game_progress)
