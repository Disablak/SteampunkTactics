class_name UiWeaponSelector
extends Control


@export var button_scene: PackedScene


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)
	GlobalBus.on_unit_changed_weapon.connect(_on_unit_changed_weapon)


func _on_unit_changed_control(id, instantly):
	_delete_previous_buttons()
	_spawn_new_weapon_buttons(id)


func _on_unit_changed_weapon(id, weapon_data: WeaponData):
	if GlobalUnits.unit_list.get_cur_unit_id() == id:
		_select_weapon(weapon_data)


func _delete_previous_buttons():
	var previous_btns = get_children()
	for btn in previous_btns:
		btn.queue_free()


func _spawn_new_weapon_buttons(id: int):
	var unit: Unit = GlobalUnits.unit_list.get_unit(id)
	var all_weapons: Array[WeaponData] = unit.unit_data.all_weapons

	var button_group = ButtonGroup.new()
	for weapon: WeaponData in all_weapons:
		var new_button: MyButton = button_scene.instantiate() as MyButton
		new_button.text = weapon.settings.setting_name
		new_button.button_group = button_group
		new_button.toggle_mode = true
		new_button.pressed.connect(func(): return _on_pressed(unit, weapon))
		add_child(new_button)

		if unit.unit_data.cur_weapon == weapon:
			new_button.set_pressed_no_signal(true)


func _on_pressed(unit: Unit, weapon_data: WeaponData):
	unit.unit_data.change_weapon(weapon_data)


func _select_weapon(weapon_data: WeaponData):
	var all_buttons = get_children()
	for button: Button in all_buttons:
		if button.text == weapon_data.settings.setting_name:
			button.set_pressed_no_signal(true)
