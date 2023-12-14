class_name FindPositionsAroundTargetAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_enemy: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY)
	var enemy_object_pos: Vector2 = target_enemy.unit_object.position

	var points_around := GlobalUtils.get_circle_points(enemy_object_pos, 15, 6)
	var filtered_points := _filter_points(points_around, actor.position)

	if filtered_points.size() == 0:
		return FAILURE

	_debug(filtered_points)
	blackboard.set_value(BehaviourAiConst.TARGET_ENEMY_AROUND_POINTS, filtered_points)

	return SUCCESS


func _filter_points(points: Array[Vector2], unit_pos: Vector2) -> Array[Vector2]:
	var valid_points: Array[Vector2]

	for point: Vector2 in points:
		var is_same_unit_pos: bool = unit_pos.distance_to(point) < 2
		if is_same_unit_pos:
			continue

		if GlobalUtils.is_point_inside_nav_polygon(point):
			valid_points.append(point)

	return valid_points


func _debug(points):
	GlobalMap.draw_debug.clear_circles("near_enemy")
	for point in points:
		GlobalMap.draw_debug.add_circle(point, "near_enemy")
