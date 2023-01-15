class_name UiUnitsList
extends Control


@export var scene_btn_unit: PackedScene


var dict_id_and_btn = {}
var prev_marked_unit_id = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(func(unit_id, tmp): mark_unit(unit_id))


func init(units_ordered: Array[int]):
	var start_pos := -30

	for id in units_ordered:
		var btn: Button = scene_btn_unit.instantiate() as Button
		add_child(btn)
		start_pos += 50
		btn.position = Vector2(40, start_pos)

		var unit: Unit = GlobalUnits.units[id]
		btn.text = "{0} - {1}".format([unit.unit_data.unit_settings.initiative, unit.unit_data.unit_settings.unit_name])
		if unit.unit_data.unit_settings.is_enemy:
			btn.disabled = true
		dict_id_and_btn[id] = btn

	mark_unit(units_ordered.front())


func mark_unit(unit_id: int):
	select_btn(prev_marked_unit_id, false)
	select_btn(unit_id, true)

	prev_marked_unit_id = unit_id


func select_btn(unit_id: int, is_select: bool):
	if not dict_id_and_btn.has(unit_id):
		return

	var btn: Button = dict_id_and_btn[unit_id] as Button
	btn.position.x = 15 if is_select else 40
