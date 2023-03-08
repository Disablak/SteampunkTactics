class_name CellCompInteractable
extends StaticBody2D


signal on_hover_obj(cell_obj: CellObject)


func _ready() -> void:
	mouse_entered.connect(_on_mouse_hover)
	mouse_exited.connect(_on_mouse_exit)


func _on_mouse_hover():
	on_hover_obj.emit(get_parent())


func _on_mouse_exit():
	on_hover_obj.emit(null)
