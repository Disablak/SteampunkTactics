extends Control



func _on_btn_move_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _on_btn_push_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _on_btn_shoot_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _on_btn_reload_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _on_btn_grenade_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _on_btn_knife_on_pressed_btn_action(action: UnitData.UnitAction) -> void:
	_change_action(action)


func _change_action(action: UnitData.UnitAction):
	var unit: Unit = GlobalUnits.unit_list.get_cur_unit()
	unit.unit_data.change_action(action)
