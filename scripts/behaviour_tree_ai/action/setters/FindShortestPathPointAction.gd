class_name FindShortestPathPointAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var points_around_target: Array[Vector2] = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY_AROUND_POINTS)

	if points_around_target.size() == 0:
		return FAILURE

	var shortest_path_point: Vector2
	var shortest_path_distance: float = 10000
	for point: Vector2 in points_around_target:
		var path = GlobalUtils.find_path(unit.origin_pos, point)
		var path_distance = GlobalUtils.get_total_distance(path)
		if path_distance < shortest_path_distance:
			shortest_path_point = path[path.size() - 1]
			shortest_path_distance = path_distance

	blackboard.set_value(BehaviourAiConst.SHORTEST_PATH_POINT, shortest_path_point)
	return SUCCESS

