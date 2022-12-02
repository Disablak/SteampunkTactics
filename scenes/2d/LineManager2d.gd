class_name Line2dManager
extends Node2D


const PATH_LINE_NAME = "path"
const RAY_LINE_NAME = "ray"


func draw_path(points, can_move):
	draw_new_line(PATH_LINE_NAME, points, Color.FOREST_GREEN if can_move else Color.RED)


func clear_path():
	clear_line(PATH_LINE_NAME)


func draw_ray(points):
	draw_new_line(RAY_LINE_NAME, points, Color.DARK_RED)


func clear_ray():
	clear_line(RAY_LINE_NAME)


func draw_new_line(name: String, points: PackedVector2Array, color: Color):
	if points.size() == 0:
		return

	var new_line_2d = Line2D.new()
	add_child(new_line_2d)

	new_line_2d.name = name
	new_line_2d.default_color = color
	new_line_2d.clear_points()

	for point in points:
		new_line_2d.add_point(point)


func clear_line(name: String):
	for line in get_children():
		var name_line: String = line.name
		if name_line.contains(name):
			line.queue_free()
