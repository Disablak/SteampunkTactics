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


func posToCellPos(pos: Vector3) -> Vector3:
	var simply = Vector3(
		stepify(pos.x, GRID_STEP),
		stepify(pos.y, GRID_STEP),
		stepify(pos.z, GRID_STEP)
	)
	
	return simply
