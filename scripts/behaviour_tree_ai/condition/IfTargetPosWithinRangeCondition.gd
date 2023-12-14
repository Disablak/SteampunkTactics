class_name IfTargetPosWithinRangeCondition
extends ConditionLeaf


var target_pos: Vector2
var range: float


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit_object: UnitObject = actor as UnitObject
	if unit_object.origin_pos.distance_to(target_pos) < range:
		return SUCCESS
	else:
		return FAILURE

