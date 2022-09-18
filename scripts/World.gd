extends Node3D


@onready var units_controller = get_node("%UnitsController")


func _on_BtnMoveUnit_toggled(button_pressed: bool) -> void:
	units_controller.move_unit_mode(button_pressed)


func _on_BtnNextTurn_button_down() -> void:
	units_controller.next_unit()


func _on_btn_unit_aim_toggled(button_pressed: bool) -> void:
	units_controller.shoot_unit_mode(button_pressed)
