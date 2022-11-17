class_name MyWorld
extends Node2D


@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager


func _ready() -> void:
	GlobalMap.world = self


func _on_btn_unit_reload_button_down() -> void:
	units_manager.reload_weapon()


func _on_btn_next_turn_button_down() -> void:
	units_manager.next_turn()


func _on_btn_move_unit_toggled(button_pressed: bool) -> void:
	units_manager.change_unit_action(Globals.UnitAction.WALK, button_pressed)


func _on_btn_unit_aim_toggled(button_pressed: bool) -> void:
	units_manager.change_unit_action(Globals.UnitAction.SHOOT, button_pressed)


func shoot_to_player():
	var player: Unit = GlobalUnits.units[0] #todo hardcode
	print("shoot! to player")
	units_manager.shooting.shoot(GlobalUnits.get_cur_unit(), player)
	units_manager.next_turn()


func walk_to_rand_cell():
	var unit_walking : WalkingModule = units_manager.walking
	unit_walking.draw_walking_cells()
	
	var walking_cells : PackedVector2Array = unit_walking.cached_walking_cells;
	var random_cell := walking_cells[randi_range(0, walking_cells.size() - 1)]
	
	units_manager.try_move_unit_to_cell(random_cell)
