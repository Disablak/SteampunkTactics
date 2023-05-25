extends Node


var gui: GUI
var input_system: InputSystem


func message(text: String):
	gui.show_message(text)
	print_debug(text)


func show_setup_tooltip(show, pos, text):
	if not gui or not gui.setup_tooltip:
		return

	gui.setup_tooltip.visible = show

	if not show:
		return

	gui.setup_tooltip.position = pos
	gui.setup_tooltip.get_node("RichTextLabel").text = text
