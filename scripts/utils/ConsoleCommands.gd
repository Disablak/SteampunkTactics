extends Node


@export var nav_region_node: Node2D



func _ready() -> void:
	_init_commands()


func _init_commands():
	Console.add_command("debug_ai", _debug_ai)
	Console.add_command("nav_on", _nav_on)
	Console.add_command("nav_off", _nav_off)


func _debug_ai():
	PrintDebug.toggle_ai()


func _nav_on():
	nav_region_node.self_modulate.a = 0.5

func _nav_off():
	nav_region_node.self_modulate.a = 0.0
