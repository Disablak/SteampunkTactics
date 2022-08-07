extends Position3D


signal on_click_world(ray_cast_result)

onready var camera = get_node("Camera")

var ray_origin
var ray_end

const ray_length = 1000


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	var is_mouse_click = event is InputEventMouseButton and event.pressed and event.button_index == 1
	if is_mouse_click:
		make_raycast(event.position)



func make_raycast(pos) -> void:
	var space_state = get_world().direct_space_state
	var from = camera.project_ray_origin(pos)
	var to = from + camera.project_ray_normal(pos) * ray_length
	var result = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
	
	if result:
		emit_signal("on_click_world", result)



