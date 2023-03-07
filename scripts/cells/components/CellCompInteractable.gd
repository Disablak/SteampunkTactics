class_name CellCompInteractable
extends Node2D


signal on_click_obj(cell_obj: CellObject)
signal on_hover_obj(cell_obj: CellObject)

@export var area2d: Area2D


func _ready() -> void:
	area2d.mouse_entered.connect(_on_mouse_hover)
	area2d.mouse_exited.connect(_on_mouse_exit)


func _on_mouse_hover():
	on_hover_obj.emit(self)


func _on_mouse_exit():
	on_hover_obj.emit(null)
