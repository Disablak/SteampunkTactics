class_name ObjectSelector
extends Node2D


const COLLISION_GROUP_NAME = "collision_interactable"

@export var camera: Camera2D

var _hovered_objects: Array[Node] = []


signal on_click_on_object(click_pos: Vector2, objects: Array[Node])


func _ready() -> void:
	GlobalMap.object_selector = self
	_subscribe_on_all_interactable_objects()


func is_any_hovered_obj() -> bool:
	return _hovered_objects.size() > 0


func get_hovered_objects() -> Array[Node]:
	return _hovered_objects


func get_hovered_unit() -> Unit:
	if not is_any_hovered_obj():
		return null

	var all_hovered_objects := get_hovered_objects()
	var first_hovered_obj := all_hovered_objects[0]
	if not first_hovered_obj is UnitObject:
		return null

	var unit_object: UnitObject = first_hovered_obj as UnitObject
	return GlobalUnits.unit_list.get_unit(unit_object.unit_id)


func unsub_interactable_object_and_update_hovered(interactable: InteractableStaticBody):
	_unsubscribe_interactable_object(interactable)
	_hovered_objects.erase(interactable.get_parent())


func _subscribe_on_all_interactable_objects():
	var all_interactable_nodes: Array[InteractableStaticBody] = _get_all_interactable_nodes()
	for interactable in all_interactable_nodes:
		_subscribe_interactable_object(interactable)


func _get_all_interactable_nodes() -> Array[InteractableStaticBody]:
	var all_interactable_nodes = get_tree().get_nodes_in_group(COLLISION_GROUP_NAME)
	var interactable_static_bodies: Array[InteractableStaticBody]
	interactable_static_bodies.assign(all_interactable_nodes)

	return interactable_static_bodies


func _subscribe_interactable_object(interactable: InteractableStaticBody):
	interactable.on_hover_object.connect(_on_hover_object)
	interactable.on_unhover_object.connect(_on_unhover_object)


func _unsubscribe_interactable_object(interactable: InteractableStaticBody):
	interactable.on_hover_object.disconnect(_on_hover_object)
	interactable.on_unhover_object.disconnect(_on_unhover_object)


func _on_hover_object(node: Node2D):
	if not _hovered_objects.has(node):
		_hovered_objects.append(node)


func _on_unhover_object(node: Node2D):
	if _hovered_objects.has(node):
		_hovered_objects.erase(node)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		var click_pos = GlobalUtils.screen_pos_to_world_pos(event.position)
		on_click_on_object.emit(click_pos, get_hovered_objects())

