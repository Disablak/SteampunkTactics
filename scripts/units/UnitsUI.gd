extends Control

@export var path_camera: NodePath
@onready var camera = get_node(path_camera)


var units_ui = {}
var label_tooltip := Label.new()

const UI_OFFSET = Vector2(-30, -30)


func _ready() -> void:
	await get_tree().root.ready

	GlobalBus.connect(GlobalBus.on_unit_change_health_name, Callable(self, "_update_unit_info"))
	GlobalBus.connect(GlobalBus.on_unit_changed_walk_distance_name, Callable(self, "_update_unit_info"))
	GlobalBus.connect(GlobalBus.on_hovered_unit_in_shooting_mode_name, Callable(self, "_on_hovered_unit_in_shooting_mode"))
	
	
	add_child(label_tooltip)
	show_tooltip(false, Vector3.ZERO, "")
	
	for unit_id in GlobalUnits.units:
		_update_unit_info(unit_id)


func _process(delta: float) -> void:
	for id in units_ui.keys():
		if not GlobalUnits.units.has(id):
			_delete_unit_ui(id)
			break
		
		var point_3d = GlobalUnits.units[id].unit_object.get_node("PositionUI")
		var position_in_ui = camera.unproject_position(point_3d.global_transform.origin)
		units_ui[id].position = position_in_ui + UI_OFFSET


func _update_unit_info(unit_id):
	if units_ui.has(unit_id):
		_update_health(unit_id)
	else:
		_create_unit_ui(unit_id)


func _update_health(unit_id):
	var unit_ui = units_ui[unit_id]
	var unit_data = GlobalUnits.units[unit_id].unit_data
	
	unit_ui.text = "HP:{0}/{1}".format([
		unit_data.cur_health, 
		unit_data.unit_settings.max_health
	])
	
	
func _create_unit_ui(unit_id):
	var new_ui = Label.new()
	add_child(new_ui)
	units_ui[unit_id] = new_ui
	_update_health(unit_id)


func _delete_unit_ui(unit_id):
	units_ui[unit_id].queue_free()
	units_ui.erase(unit_id)


func show_tooltip(show, world_pos, text):
	label_tooltip.visible = show
	
	if not show:
		label_tooltip.position = Vector2(9999, 9999)
		return
	
	label_tooltip.text = text
	
	var position_in_ui = camera.unproject_position(world_pos)
	label_tooltip.position = position_in_ui


func _on_hovered_unit_in_shooting_mode(is_hover, world_pos, text) -> void:
	show_tooltip(is_hover, world_pos, text)
