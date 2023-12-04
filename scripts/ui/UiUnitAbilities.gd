class_name UiUnitAbilities
extends Control


@export var btns_container: Control

var all_btns_ability = {}


func _ready() -> void:
	GlobalBus.on_unit_updated_weapon.connect(_on_unit_updated_weapon)
	GlobalBus.on_unit_changed_action.connect(_on_changed_action)


func update_all_abilities(unit_data: UnitData):
	_init_all_buttons(unit_data)
	_on_unit_updated_weapon(unit_data.unit_id, unit_data.riffle)
	_on_unit_updated_weapon(unit_data.unit_id, unit_data.grenade)


func _init_all_buttons(unit_data: UnitData):
	if all_btns_ability.size() != 0:
		return

	for btn in btns_container.get_children():
		var button: Button = btn as Button
		var is_btn_available = unit_data.has_ability(button.ability)
		button.pressed.connect(func(): _on_clicked_ability(btn))
		button.visible = is_btn_available

		all_btns_ability[button.ability] = button


func _on_clicked_ability(btn):
	GlobalBus.on_clicked_ability.emit(btn.ability)


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

	if all_btns_ability.size() == 0:
		return false

	return true


func _update_riffle_btn_text(riffle: RangedWeaponData):
	all_btns_ability[UnitData.UnitAction.SHOOT].text = "Shoot ({0}/{1})".format([riffle.cur_weapon_ammo, riffle.settings.max_ammo])


func _update_grenade_btn_text(grenade: ThrowItemData):
	all_btns_ability[UnitData.UnitAction.GRENADE].text = "Grenade ({0}/{1})".format([grenade.cur_count, grenade.throw_item_settings.max_count])


func _on_changed_action(_id, action):
	if not GlobalMap.can_show_cur_unit():
		return

	for btn in all_btns_ability.values():
		btn.set_pressed_no_signal(false)

	if all_btns_ability.has(action):
		all_btns_ability[action].set_pressed_no_signal(true)


