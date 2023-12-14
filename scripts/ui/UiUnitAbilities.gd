class_name UiUnitAbilities
extends Control


@export var btns_container: Control

var _all_btns_ability = {}


func _ready() -> void:
	GlobalBus.on_unit_changed_action.connect(_on_changed_action)
	GlobalBus.on_unit_changed_control.connect(_on_unit_changed_control)
	GlobalBus.on_unit_changed_weapon.connect(_on_unit_changed_weapon)
	GlobalBus.on_unit_updated_weapon.connect(_on_unit_updated_weapon)

	for btn: ButtonUnitAction in btns_container.get_children():
		_all_btns_ability[btn.ability] = btn



func _on_unit_changed_weapon(id, weapon_data: WeaponData):
	_on_unit_changed_control(id, false)


func _on_unit_changed_control(id, instantly):
	if not GlobalUnits.unit_list.is_unit_exist(id):
		return

	var unit_data: UnitData = GlobalUnits.unit_list.get_unit(id).unit_data
	_update_all_abilities(unit_data)


func _update_all_abilities(unit_data: UnitData):
	_update_all_buttons(unit_data)
	_on_unit_updated_weapon(unit_data.unit_id, unit_data.cur_weapon)


func _update_all_buttons(unit_data: UnitData):
	var available_actions: Array[UnitData.UnitAction] = unit_data.get_available_actions()
	for button: ButtonUnitAction in btns_container.get_children():
		var is_btn_available = available_actions.has(button.ability)
		button.visible = is_btn_available


func _on_unit_updated_weapon(unit_id: int, weapon: WeaponData):
	if not _can_show_updated_weapon(unit_id):
		return

	if weapon is RangedWeaponData:
		_update_riffle_btn_text(weapon)
	elif weapon is ThrowItemData:
		_update_grenade_btn_text(weapon)


func _can_show_updated_weapon(unit_id: int) -> bool:
	if unit_id != GlobalUnits.unit_list.get_cur_unit_id():
		return false

	if _all_btns_ability.size() == 0:
		return false

	return true


func _update_riffle_btn_text(riffle: RangedWeaponData):
	_all_btns_ability[UnitData.UnitAction.SHOOT].text = "Shoot ({0}/{1})".format([riffle.cur_weapon_ammo, riffle.settings.max_ammo])


func _update_grenade_btn_text(grenade: ThrowItemData):
	_all_btns_ability[UnitData.UnitAction.GRENADE].text = "Grenade ({0}/{1})".format([grenade.cur_count, grenade.throw_item_settings.max_count])


func _on_changed_action(_id: int, action: UnitData.UnitAction):
	for btn: ButtonUnitAction in _all_btns_ability.values():
		btn.set_pressed_no_signal(false)

	if _all_btns_ability.has(action):
		_all_btns_ability[action].set_pressed_no_signal(true)

