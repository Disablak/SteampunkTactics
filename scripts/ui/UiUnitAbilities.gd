class_name UiUnitAbilities
extends Control


var all_btns_ability: Array


func init(unit_data: UnitData):
	all_btns_ability = get_child(0).get_children()

	for btn in all_btns_ability:
		var is_btn_available = unit_data.unit_settings.abilities.has(btn.ability)
		btn.visible = is_btn_available
