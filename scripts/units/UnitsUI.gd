extends Control

export(NodePath) var path_camera
onready var camera = get_node(path_camera)


var units_ui = {}

const UI_OFFSET = Vector2(-30, -30)


func _ready() -> void:
	yield(get_tree().root, "ready")

	GlobalBus.connect(GlobalBus.on_unit_change_health_name, self, "_update_unit_info")
	GlobalBus.connect(GlobalBus.on_unit_changed_walk_distance, self, "_update_unit_info")
	
	for unit_id in GlobalUnits.units:
		_update_unit_info(unit_id)

func _process(delta: float) -> void:
	for id in units_ui.keys():
		if not GlobalUnits.units.has(id):
			_delete_unit_ui(id)
			break
		
		var point_3d = GlobalUnits.units[id].unit_object.get_node("PositionUI")
		var position_in_ui = camera.unproject_position(point_3d.global_transform.origin)
		units_ui[id].rect_position = position_in_ui + UI_OFFSET


func _update_unit_info(unit_id):
	if units_ui.has(unit_id):
		_update_health(unit_id)
	else:
		_create_unit_ui(unit_id)


func _update_health(unit_id):
	var unit_ui = units_ui[unit_id]
	var unit_data = GlobalUnits.units[unit_id].unit_data
	
	unit_ui.text = "HP:{0}/{1}\nMP:{2}".format([
		unit_data.cur_health, 
		unit_data.max_health, 
		"%0.2f" % unit_data.cur_walk_distance
	])
	
	
func _create_unit_ui(unit_id):
	var new_ui = Label.new()
	add_child(new_ui)
	units_ui[unit_id] = new_ui
	_update_health(unit_id)


func _delete_unit_ui(unit_id):
	units_ui[unit_id].queue_free()
	units_ui.erase(unit_id)