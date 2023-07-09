class_name MyButton
extends Button


var _ability_setting_data: AbilitySettings
var click_action: Callable


func _ready() -> void:
	pressed.connect(_on_click)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exit)


func set_data(ability_settings: AbilitySettings):
	_ability_setting_data = ability_settings
	tooltip_text = "some text"


func get_data():
	return _ability_setting_data


func _get_text_abilitity() -> String:
	if not _ability_setting_data:
		return ""

	return _ability_setting_data.to_string()


func _on_click():
	if click_action:
		click_action.call()
		_hide_tooltip()


func _on_mouse_entered():
	if not _ability_setting_data:
		return

	GlobalsUi.show_setup_tooltip(true, get_viewport().get_mouse_position(), _get_text_abilitity())


func _on_mouse_exit():
	_hide_tooltip()


func _hide_tooltip():
	GlobalsUi.show_setup_tooltip(false, global_position, "")
