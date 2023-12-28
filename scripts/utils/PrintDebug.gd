class_name PrintDebug
extends Node


static var enabled_ai: bool = false


static func toggle_ai():
	enabled_ai = !enabled_ai
	print("debug ai enabled = ", enabled_ai)


static func print_ai(text):
	if enabled_ai:
		print(text)
