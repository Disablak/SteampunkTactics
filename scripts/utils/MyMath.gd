class_name MyMath
extends Node


static func arr_add_no_copy(arr0: Array, arr1: Array) -> Array:
	for element in arr1:
		if arr0.has(element):
			continue

		arr0.append(element)

	return arr0


static func arr_except(arr0: Array, arr1: Array) -> Array:
	var diff: Array
	for element in arr0:
		if arr1.has(element):
			continue

		diff.append(element)

	return diff


static func get_circle_points(center: Vector2, radius: int) -> Array[Vector2]:
	var x := radius
	var y := 0

	var all_points: Array[Vector2]

	all_points.append(Vector2(center.x + x, center.y))

	if radius > 0:
		all_points.append(Vector2(center.x - x, center.y))
		all_points.append(Vector2(center.x, center.y + x))
		all_points.append(Vector2(center.x, center.y - x))

	var p: int = 1 - radius

	while x > y:
		y += 1

		if p <= 0:
			p = p + 2 * y + 1
		else:
			x -= 1
			p = p + 2 * y - 2 * x + 1;

		if x < y:
			break

		all_points.append(Vector2(center.x + x, center.y + y))
		all_points.append(Vector2(center.x - x, center.y + y))
		all_points.append(Vector2(center.x + x, center.y - y))
		all_points.append(Vector2(center.x - x, center.y - y))

		if x == y:
			continue

		all_points.append(Vector2(center.x + y, center.y + x))
		all_points.append(Vector2(center.x - y, center.y + x))
		all_points.append(Vector2(center.x + y, center.y - x))
		all_points.append(Vector2(center.x - y, center.y - x))

	return all_points



static func bresenham_line_perfect(from:Vector2, to: Vector2):
	var dx: int = abs(to.x - from.x)
	var sx: int = 1 if from.x < to.x else -1
	var dy: int = -abs(to.y - from.y)
	var sy: int = 1 if from.y < to.y else -1

	var error: int = dx + dy

	var points: Array[Vector2]

	while true:
		points.append(Vector2(from.x, from.y))

		if from.x == to.x && from.y == to.y:
			break

		var e2 = 2 * error
		if e2 >= dy:
			if from.x == to.x:
				break

			error += + dy
			from.x += + sx

		if e2 <= dx:
			if from.y == to.y:
				break

			error += dx
			from.y += sy

	return points


static func bresenham_line_thick(from:Vector2, to: Vector2):
	var points: Array[Vector2]

	var xinc: int = -1 if (to.x < from.x) else 1;
	var yinc: int = -1 if (to.y < from.y) else 1;
	var dx: int = xinc * (to.x - from.x);
	var dy: int = yinc * (to.y - from.y);

	var side: int
	var i: int
	var error: int

	points.append(from)

	if dx == dy:
		while dx > 0:
			dx -= 1
			from.x += xinc
			from.y += yinc
			points.append(from)

		return points

	side = -1 * ((yinc if dx == 0 else xinc) - 1);

	i     = dx + dy;
	error = dx - dy;

	dx *= 2;
	dy *= 2;

	while i > 0:
		i -= 1
		if error > 0 or error == side:
			from.x += xinc;
			error  -= dy;
		else:
			from.y += yinc;
			error  += dx;

		points.append(from)

	return points
