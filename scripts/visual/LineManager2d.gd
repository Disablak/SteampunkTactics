class_name Line2dManager
extends Node2D


@export var line_2d_scrolling: PackedScene

const PATH_LINE_NAME = "path"
const RAY_LINE_NAME = "ray"
const LINE_TRAJECTORY_NAME = "trajectory"
const SHOOT_RAY = "shoot_effect"

const GRAVITY = -9.8
const POINTS_IN_TRAJECTORY = 20

var line2d_trajectory: Line2D


func draw_shoot_ray(points):
	return draw_new_line(null, SHOOT_RAY, _points_with_offset(points), Color.YELLOW, 2)


func clear_shoot_ray():
	clear_line(SHOOT_RAY)


func draw_path(points, can_move):
	draw_scrolling_new_line(PATH_LINE_NAME, _points_with_offset(points), Color.FOREST_GREEN if can_move else Color.RED)


func clear_path():
	clear_line(PATH_LINE_NAME)


func draw_ray(points):
	draw_scrolling_new_line(RAY_LINE_NAME, points, Color.DARK_RED)


func clear_ray():
	clear_line(RAY_LINE_NAME)


func draw_trajectory(start: Vector2, end: Vector2, enough_distance: bool):
	if line2d_trajectory == null:
		line2d_trajectory = draw_scrolling_new_line(LINE_TRAJECTORY_NAME, [Vector2.ZERO], Color.ORANGE_RED)

	_color_line(line2d_trajectory, Color.ORANGE_RED if enough_distance else Color.DARK_RED)
	_draw_trajectory(line2d_trajectory, start, end)


func clear_trajectory():
	clear_line(LINE_TRAJECTORY_NAME)


func draw_new_line(scene: PackedScene, name: String, points: Array[Vector2], color: Color, width: int = 20) -> Line2D:
	if points.size() == 0:
		return null

	var new_line_2d: Line2D
	if scene == null:
		new_line_2d = Line2D.new() as Line2D
	else:
		new_line_2d = scene.instantiate() as Line2D

	add_child(new_line_2d)

	new_line_2d.name = name
	new_line_2d.width = width
	new_line_2d.default_color = color
	new_line_2d.clear_points()

	for point in points:
		new_line_2d.add_point(point)

	return new_line_2d


func draw_scrolling_new_line(name: String, points: Array[Vector2], color: Color, width: int = 20) -> Line2D:
	var line := draw_new_line(line_2d_scrolling, name, points, color, width)
	if line == null:
		return null

	line.material = line.material.duplicate()
	_color_line(line, color)

	return line


func clear_line(name: String):
	for line in get_children():
		var name_line: String = line.name
		if name_line.contains(name):
			line.queue_free()


func _color_line(line2d: Line2D, color: Color):
	line2d.material.set_shader_parameter("color", color)


func _draw_trajectory(line2d: Line2D, start: Vector2, end: Vector2): # magic is here!
	if start.x == end.x: # haha kostil works!
		start += Vector2(2, 0)

	var dot := Vector2(1, 0).dot((end - start).normalized())
	var angle := 90 - 45 * dot
	var x_dis :=   end.x - start.x
	var y_dis := -(end.y - start.y)

	var speed := sqrt(abs(((0.5 * GRAVITY * x_dis * x_dis) / pow(cos(deg_to_rad(angle)), 2.0)) / (y_dis - (tan(deg_to_rad(angle)) * x_dis))))

	var x_comp := cos(deg_to_rad(angle)) * speed
	var y_comp := sin(deg_to_rad(angle)) * speed

	var total_time := x_dis / x_comp

	var points: Array[Vector2]

	line2d.clear_points()

	for point in POINTS_IN_TRAJECTORY + 1:
		var t: float = float(point) / POINTS_IN_TRAJECTORY
		var time = total_time * t
		var dx = time * x_comp
		var dy = -1.0 * time * (y_comp + 0.5 * GRAVITY * time)

		line2d.add_point(start + Vector2(dx, dy))


func _points_with_offset(points) -> Array[Vector2]:
	var result: Array[Vector2] = []

	for point in points:
		point += Globals.CELL_OFFSET
		result.append(point)

	return result
