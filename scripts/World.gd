class_name MyWorld
extends Node2D


@onready var units_manager: UnitsManager = $UnitsManager as UnitsManager


func _ready() -> void:
	GlobalMap.world = self


func _on_btn_unit_reload_button_down() -> void:
	units_manager.reload_weapon()


func _on_btn_next_turn_button_down() -> void:
	units_manager.next_unit()


func _on_btn_move_unit_toggled(button_pressed: bool) -> void:
	units_manager.change_unit_action(Globals.UnitAction.WALK, button_pressed)


func _on_btn_unit_aim_toggled(button_pressed: bool) -> void:
	units_manager.change_unit_action(Globals.UnitAction.SHOOT, button_pressed)
