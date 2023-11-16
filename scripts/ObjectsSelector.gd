class_name ObjectsSelector
extends Node2D


var _camera: Camera2D
var _hovered_objects: Array[Node] = []


signal on_click_on_object(click_pos: Vector2, objects: Array[Node])


func _ready() -> void:
	_subscribe_on_all_interactable_objects()


func inject_data(camera: Camera2D):
	_camera = camera


func is_any_hovered_obj() -> bool:
	return _hovered_objects.size() > 0


func get_hovered_objects() -> Array[Node]:
	return _hovered_objects


func _subscribe_on_all_interactable_objects():
	var all_interactable_nodes: Array[InteractableStaticBody] = _get_all_interactable_nodes()
	for interactable in all_interactable_nodes:
		_subscribe_interactable_object(interactable)


func _get_all_interactable_nodes() -> Array[InteractableStaticBody]:
	var all_interactable_nodes = get_tree().get_nodes_in_group("collision_interactable")
	var interactable_static_bodies: Array[InteractableStaticBody]
	interactable_static_bodies.assign(all_interactable_nodes)

	return interactable_static_bodies


func _subscribe_interactable_object(interactable: InteractableStaticBody):
	interactable.on_hover_object.connect(_on_hover_object)
	interactable.on_unhover_object.connect(_on_unhover_object)


func _on_hover_object(node: Node2D):
	if not _hovered_objects.has(node):
		_hovered_objects.append(node)
	print(_hovered_objects.size())


func _on_unhover_object(node: Node2D):
	if _hovered_objects.has(node):
		_hovered_objects.erase(node)
	print(_hovered_objects.size())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		var click_pos = formatted_position(event.position)
		on_click_on_object.emit(click_pos, get_hovered_objects())
		print(click_pos)


func formatted_position(position: Vector2) -> Vector2:
	var view_size := _camera.get_viewport_rect().size
	var camera_offset = _camera.position - (view_size / 2)
	var camera_zoomed_pos = ((view_size / 2) - ((view_size / _camera.zoom) / 2))
	return camera_zoomed_pos + camera_offset + position / _camera.zoom

