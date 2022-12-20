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


const GRID_STEP = 1.0
const CURVE_X_METERS = 3000
const CELL_SIZE := 32
const CELL_HALF_SIZE := CELL_SIZE / 2
const CELL_OFFSET := Vector2(CELL_HALF_SIZE, CELL_HALF_SIZE)



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


static func format_hit_chance(hit_chance: float) -> String:
	return "%0.1f" % (hit_chance * 100) + "%"


