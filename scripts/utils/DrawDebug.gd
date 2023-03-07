class_name DrawDebug
extends Node2D


var lines: Array[Array]


func clear_draw_vision_lines():
	lines.clear()
	queue_redraw()


func draw_vision_lines(line: Array):
	lines.append(line)
	queue_redraw()


func _draw() -> void:
	draw_fog_of_war_raycast()


func draw_fog_of_war_raycast():
	if not Globals or not Globals.DEBUG_FOW_RAYCASTS:
		return

	if lines.size() == 0:
		return

	for line in lines:
		draw_line(line[0], line[1], Color.WHITE)
