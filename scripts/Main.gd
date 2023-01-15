extends Node3D


@onready var world = $World
@onready var gui = $GUI as GUI


func _ready() -> void:
	gui.init()
