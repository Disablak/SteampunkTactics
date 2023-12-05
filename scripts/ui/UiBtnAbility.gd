class_name ButtonUnitAction
extends Button


signal on_pressed_btn_action(ability: UnitData.UnitAction)

@export var ability: UnitData.UnitAction = UnitData.UnitAction.NONE


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	on_pressed_btn_action.emit(ability)
