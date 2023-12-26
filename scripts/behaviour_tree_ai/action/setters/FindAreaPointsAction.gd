class_name FindAreaPointsAction
extends ActionLeaf


@export var area: Vector2 = Vector2(200, 200)
@export var distance: float = 20


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit_pos = (actor as UnitObject).origin_pos
	var points: Array[Vector2] = GlobalUtils.get_area_of_points(unit_pos, area, distance, randf_range(0, 90))
	points = GlobalUtils.get_points_inside_nav_polygon(points)

	blackboard.set_value(BehaviourAiConst.AREA_POINTS, points)
	return SUCCESS

