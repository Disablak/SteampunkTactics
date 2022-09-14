class_name ActionMove
extends Action


func execute():
	var temp_pos = Vector3(10, 0, 0)
	GlobalUnits.units_controller.walking_system.move_unit(temp_pos)
