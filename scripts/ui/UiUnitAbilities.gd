class_name UiUnitAbilities
extends Control


var all_btns_ability = {}


func _ready() -> void:
	GlobalBus.on_unit_updated_weapon.connect(_on_unit_changed_ammo)
	GlobalBus.on_unit_changed_action.connect(_on_changed_action)


func init(unit_data: UnitData):
	_init_all_buttons(unit_data)
	_on_unit_changed_ammo(unit_data.unit_id, unit_data.riffle)


func _init_all_buttons(unit_data: UnitData):
	if all_btns_ability.size() != 0:
		return

	for btn in get_child(0).get_child(0).get_children():
		var button: Button = btn as Button
		var is_btn_available = unit_data.has_ability(button.ability)
		button.pressed.connect(func(): _on_clicked_ability(btn))
		button.visible = is_btn_available

		all_btns_ability[button.ability] = button


func _on_clicked_ability(btn):
	GlobalBus.on_clicked_ability.emit(btn.ability)


func _on_unit_changed_ammo(unit_id, weapon):
	if not GlobalMap.can_show_cur_unit():
		return

	if unit_id != GlobalUnits.cur_unit_id:
		return

	if not weapon is RangedWeaponData:
		return

	if all_btns_ability.size() == 0:
		return

	all_btns_ability[UnitData.Abilities.SHOOT].text = "Shoot ({0}/{1})".format([weapon.cur_weapon_ammo, weapon.settings.max_ammo])


func _on_changed_action(_id, action):
	if not GlobalMap.can_show_cur_unit():
		return

	for btn in all_btns_ability.values():
		btn.set_pressed_no_signal(false)

	if all_btns_ability.has(action):
		all_btns_ability[action].set_pressed_no_signal(true)
