class_name FilterAreaPointsByDistanceToEnemyAction
extends ActionLeaf


@export var is_distance_more := true
@export var distance := 100


func tick(actor: Node, blackboard: Blackboard) -> int:
	var nearest_enemy: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY) as Unit
	var points: Array[Vector2] = blackboard.get_value(BehaviourAiConst.AREA_POINTS) as Array[Vector2]

	var filtered_points: Array[Vector2]
	if is_distance_more:
		filtered_points = points.filter(func(x): return nearest_enemy.origin_pos.distance_to(x) > distance)
	else:
		filtered_points = points.filter(func(x): return nearest_enemy.origin_pos.distance_to(x) <= distance)

	_debug(filtered_points)
	blackboard.set_value(BehaviourAiConst.MOVE_POSES, filtered_points)
	return SUCCESS


func _debug(points):
	GlobalMap.draw_debug.clear_circles("area")
	for point in points:
		GlobalMap.draw_debug.add_circle(point, "area")
