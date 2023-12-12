class_name IfTargetPosWithinRangeCondition
extends ConditionLeaf


var target_pos: Vector2
var range: float


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.position.distance_to(target_pos) < range:
		return SUCCESS
	else:
		return FAILURE

