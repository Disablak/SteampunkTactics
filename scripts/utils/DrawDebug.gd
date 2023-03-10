class_name DrawDebug
extends Node2D


var lines: Array[Array]
var point_ordering = {} # pos and ordering


func clear_draw_vision_lines():
	lines.clear()
	queue_redraw()


func draw_vision_lines(line: Array):
	lines.append(line)
	queue_redraw()


func draw_object_order_point(pos: Vector2, ordering: int):
	point_ordering[pos] = ordering
	queue_redraw()


func clear_points_ordering():
	point_ordering.clear()
	queue_redraw()


func _draw() -> void:
	_draw_fog_of_war_raycast()
	_draw_objects_ordering()


func _draw_fog_of_war_raycast():
	if not Globals or not Globals.DEBUG_FOW_RAYCASTS:
		return

	for line in lines:
		draw_line(line[0], line[1], Color.WHITE)


func _draw_objects_ordering():
	if not Globals or not Globals.DEBUG_OBJECTS_ORDERING:
		return

	for point in point_ordering:
		draw_circle(point, 1, Color.BLUE_VIOLET)
		var ordering: String = str(point_ordering[point])
		draw_string(ThemeDB.fallback_font, point, ordering, HORIZONTAL_ALIGNMENT_LEFT, -1, 5)
