class_name Line2dManager
extends Node2D


var all_lines = {} # String / Line2d


func draw_new_line(name: String, points: PackedVector2Array, color: Color):
	var new_line_2d: Line2D = null
	
	if all_lines.has(name):
		new_line_2d = all_lines[name]
	else:
		new_line_2d = Line2D.new()
		add_child(new_line_2d)
		all_lines[name] = new_line_2d
	
	new_line_2d.name = name
	new_line_2d.default_color = color
	new_line_2d.clear_points()
	
	for point in points:
		new_line_2d.add_point(point)


func clear_line(name: String):
	if all_lines.has(name):
		var line_2d: Line2D = all_lines[name]
		line_2d.clear_points()
	else:
		print("line with name {0} not exist".format([name]))
