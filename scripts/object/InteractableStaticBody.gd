class_name InteractableStaticBody
extends StaticBody2D


signal on_hover_object(node: Node2D)
signal on_unhover_object(node: Node2D)


func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover)
	mouse_exited.connect(_on_mouse_exit)


func _exit_tree() -> void:
	GlobalMap.object_selector.unsub_interactable_object_and_update_hovered(self)


func _on_mouse_hover():
	on_hover_object.emit(get_parent())


func _on_mouse_exit():
	on_unhover_object.emit(get_parent())


func enable_collision():
	$Collision.disabled = false


func disable_collision():
	$Collision.disabled = true
