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
	RELOAD,
	GRANADE
}

const CELL_AREA_3x3: Array[Vector2]= [
	Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT,
	Vector2.UP, Vector2.DOWN, Vector2(1, 1),
	Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)]

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


static func snap_to_cell_pos(pos: Vector2) -> Vector2:
	return Vector2(snappedi(pos.x, CELL_SIZE), snappedi(pos.y, CELL_SIZE))


static func get_cells_of_type(cells: Array, cell_type: CellObject.CellType):
	var result = []
	for cell in cells:
		if cell is CellObject and cell.cell_type == cell_type:
			result.append(cell)

	return result


func create_timer_and_get_signal(time: float) -> Signal:
	return get_tree().create_timer(time).timeout
