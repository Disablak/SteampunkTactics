extends Control


@export var unit_ui_scene: PackedScene


var units_ui = {}
var label_tooltip := Label.new()

const UI_OFFSET = -Globals.CELL_OFFSET + Vector2(0, -20)


func _ready() -> void:
	GlobalBus.on_unit_change_health.connect(_update_unit_info)
	GlobalBus.on_unit_changed_walk_distance.connect(_update_unit_info)
	GlobalBus.on_unit_changed_action.connect(_on_unit_changed_action)

	add_child(label_tooltip)
	show_tooltip(false, Vector3.ZERO, "")

	for unit_id in GlobalUnits.units:
		_update_unit_info(unit_id)


func _process(delta: float) -> void:
	for id in units_ui.keys():
		if not GlobalUnits.units.has(id):
			_delete_unit_ui(id)
			return

		var unit_object = GlobalUnits.units[id].unit_object
		if unit_object == null:
			_delete_unit_ui(id)
			return

		if not unit_object.is_visible:
			_hide_unit_ui(id)
			continue

		var position_in_ui = unit_object.position
		units_ui[id].position = position_in_ui + UI_OFFSET
		units_ui[id].scale = Vector2.ONE / get_viewport().get_camera_2d().zoom


func _update_unit_info(unit_id, dealer_unit_id):
	if units_ui.has(unit_id):
		_update_health(unit_id)
	else:
		_create_unit_ui(unit_id)


func _update_health(unit_id, is_first_create = false):
	var unit_ui = units_ui[unit_id]
	var unit_data = GlobalUnits.units[unit_id].unit_data

	unit_ui.set_hp(unit_data.cur_health, unit_data.max_health)

	if is_first_create:
		unit_ui.set_action(0)

	if GlobalUnits.units_manager.cur_unit_id == unit_id:
		unit_ui.set_action(GlobalUnits.units_manager.cur_unit_action)
	else:
		unit_ui.clear_action()


func _create_unit_ui(unit_id):
	var new_ui = unit_ui_scene.instantiate()
	add_child(new_ui)
	units_ui[unit_id] = new_ui
	_update_health(unit_id, true)


func _delete_unit_ui(unit_id):
	units_ui[unit_id].queue_free()
	units_ui.erase(unit_id)


func _hide_unit_ui(unit_id):
	units_ui[unit_id].position = Vector2.ZERO


func _get_unit_ui(unit_id):
	if units_ui.has(unit_id):
		return units_ui[unit_id]

	return null


func show_tooltip(show, world_pos, text):
	label_tooltip.visible = show

	if not show:
		label_tooltip.position = Vector2(9999, 9999)
		return

	label_tooltip.text = text


func _on_unit_changed_action(unit_id, unit_action):
	var unit_ui = _get_unit_ui(unit_id)
	if unit_ui != null:
		unit_ui.set_action(unit_action)
