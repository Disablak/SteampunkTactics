extends Control


func _ready() -> void:
	GlobalBus.on_unit_changed_action.connect(_on_changed_action)


func _on_changed_action(unit_id: int, action: UnitData.UnitAction):
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_id)
	unit.unit_data.change_action(action)
