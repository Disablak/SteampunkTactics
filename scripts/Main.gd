extends Node3D


@onready var world = $World
@onready var gui = $GUI as GUI

@export var level_id := 0


func _ready() -> void:
	world.init(level_id)
	gui.init()
