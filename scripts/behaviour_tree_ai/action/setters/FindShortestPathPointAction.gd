class_name FindShortestPathPointAction
extends ActionLeaf


@export var key_points_array := "move_poses"


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var target_points: Array[Vector2] = blackboard.get_value(key_points_array)

	if target_points.size() == 0:
		return FAILURE

	var shortest_path_point: Vector2
	var shortest_path_distance: float = 10000
	for point: Vector2 in target_points:
		var path = GlobalUtils.find_path(unit.origin_pos, point)
		var path_distance = GlobalUtils.get_total_distance(path)
		if path_distance < shortest_path_distance:
			shortest_path_point = path[path.size() - 1]
			shortest_path_distance = path_distance

	blackboard.set_value(BehaviourAiConst.SHORTEST_PATH_POINT, shortest_path_point)
	return SUCCESS

