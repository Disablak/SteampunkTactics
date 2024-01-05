class_name UiUnitsList
extends Control


@export var scene_btn_unit: PackedScene


var dict_id_and_btn = {}
var prev_marked_unit_id = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(func(unit_id, tmp): mark_unit(unit_id))
	GlobalBus.on_unit_died.connect(func(id, killer_id): _update_btns())


func init(units_ordered: Array[int]):
	_remove_all_btns()

	for id in units_ordered:
		var btn: Button = scene_btn_unit.instantiate() as Button
		add_child(btn)

		var unit: Unit = GlobalUnits.unit_list.get_unit(id)
		btn.visible = true
		btn.text = _text(unit, false)
		dict_id_and_btn[id] = btn

	mark_unit(units_ordered.front())


func _remove_all_btns():
	for child in get_children():
		child.queue_free()

	dict_id_and_btn.clear()
	prev_marked_unit_id = -1


func _update_btns():
	for unit_id in dict_id_and_btn:
		var is_unit_alive = GlobalUnits.unit_list.is_unit_exist(unit_id)
		dict_id_and_btn[unit_id].visible = is_unit_alive


func mark_unit(unit_id: int):
	select_btn(prev_marked_unit_id, false)
	select_btn(unit_id, true)

	prev_marked_unit_id = unit_id


func select_btn(unit_id: int, is_select: bool):
	if not dict_id_and_btn.has(unit_id):
		return

	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_id)
	var btn: Button = dict_id_and_btn[unit_id] as Button
	var str_selected = "->"
	btn.text = _text(unit, is_select)


func _text(unit, is_selected) -> String:
	return "{0} {1} - {2}".format(["->" if is_selected else "", unit.unit_data.initiative, unit.unit_data.unit_name])
