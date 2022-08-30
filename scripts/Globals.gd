extends Node


enum AnimationType{
	NONE,
	IDLE,
	WALKING,
	SHOOTING,
	HIT,
}

enum UnitAction{
	NONE,
	WALK,
	SHOOT,
}

const GRID_STEP = 1.0
const CURVE_X_METERS = 40


static func posToCellPos(pos: Vector3) -> Vector3:
	var simply = Vector3(
		stepify(pos.x, GRID_STEP),
		stepify(pos.y, GRID_STEP),
		stepify(pos.z, GRID_STEP)
	)
	
	return simply


static func get_total_distance(points: PoolVector3Array) -> float:
	if points.size() <= 1:
		return 0.0
	
	var distance = 0.0
	var start: Vector3 = points[0]
	
	for i in range(1, points.size()):
		var end = points[i]
		distance += start.distance_to(end)
		start = points[i]
	
	return distance
