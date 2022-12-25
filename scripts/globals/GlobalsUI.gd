extends Node


var gui: GUI
var input_system: InputSystem


func message(text: String):
	gui.show_message(text)
	print_debug(text)
