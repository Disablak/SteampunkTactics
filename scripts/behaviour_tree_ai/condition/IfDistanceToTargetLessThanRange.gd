class_name IfDistanceToTargetLessThanRange
extends ConditionLeaf


@export var range: float = 100


func tick(actor: Node, blackboard: Blackboard) -> int:
	var cur_unit: Unit = GlobalUnits.get_unit((actor as UnitObject).unit_id) as Unit
	var enemy_unit: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY) as Unit

	if cur_unit.origin_pos.distance_to(enemy_unit.origin_pos) < range:
		return SUCCESS
	else:
		return FAILURE

