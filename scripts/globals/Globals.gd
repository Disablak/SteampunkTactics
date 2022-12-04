extends Node


enum AnimationType{
	NONE,
	IDLE,
	WALKING,
	SHOOTING,
	HIT,
	RELOADING,
}

enum UnitAction{
	NONE,
	WALK,
	SHOOT,
	RELOAD
}

enum MouseHoverType{
	NONE,
	GROUND,
	OBSTACLE,
	UNIT
}

const GRID_STEP = 1.0
const CURVE_X_METERS = 3000
const CELL_SIZE := 64
const CELL_OFFSET := Vector2(CELL_SIZE / 2, CELL_SIZE / 2)


static func posToCellPos(pos: Vector3) -> Vector3:
	var simply = Vector3(
		snapped(pos.x, GRID_STEP),
		snapped(pos.y, GRID_STEP),
		snapped(pos.z, GRID_STEP)
	)

	return simply


static func get_total_distance(points: PackedVector2Array) -> float:
	if points.size() <= 1:
		return 0.0

	var distance = 0.0
	var start: Vector2 = points[0]

	for i in range(1, points.size()):
		var end = points[i]
		distance += start.distance_to(end)
		start = points[i]

	return distance

static func convert_to_tile_pos(rect_pos : Vector2) -> Vector2:
	return floor(rect_pos / CELL_SIZE)

static func convert_to_rect_pos(tile_pos : Vector2) -> Vector2:
	return tile_pos * CELL_SIZE + CELL_OFFSET


static func convert_tile_points_to_rect(points: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()

	for point in points:
		result.push_back(convert_to_rect_pos(point))

	return result


static func format_hit_chance(hit_chance: float) -> String:
	return "%0.1f" % (hit_chance * 100)


