class_name UiUnitsList
extends Control


@export var scene_btn_unit: PackedScene


var dict_id_and_btn = {}
var prev_marked_unit_id = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(func(unit_id, tmp): mark_unit(unit_id))
	GlobalBus.on_unit_moved_to_another_cell.connect(func(id, cell_pos): _update_btns())


func init(units_ordered: Array[int]):
	for id in units_ordered:
		var btn: Button = scene_btn_unit.instantiate() as Button
		add_child(btn)

		var unit: Unit = GlobalUnits.units[id]
		btn.visible = GlobalMap.can_show_unit(id)
		btn.text = _text(unit, false)
		dict_id_and_btn[id] = btn

	mark_unit(units_ordered.front())


func _update_btns():
	for unit_id in dict_id_and_btn:
		var is_unit_alive = GlobalUnits.units.has(unit_id)
		dict_id_and_btn[unit_id].visible = is_unit_alive and GlobalMap.can_show_unit(unit_id)


func mark_unit(unit_id: int):
	if not GlobalMap.can_show_unit(unit_id):
		return

	select_btn(prev_marked_unit_id, false)
	select_btn(unit_id, true)

	prev_marked_unit_id = unit_id


func select_btn(unit_id: int, is_select: bool):
	if not dict_id_and_btn.has(unit_id):
		return

	var unit: Unit = GlobalUnits.units[unit_id]
	var btn: Button = dict_id_and_btn[unit_id] as Button
	var str_selected = "->"
	btn.text = _text(unit, is_select)


func _text(unit, is_selected) -> String:
	return "{0} {1} - {2}".format(["->" if is_selected else "", unit.unit_data.unit_settings.initiative, unit.unit_data.unit_settings.unit_name])
