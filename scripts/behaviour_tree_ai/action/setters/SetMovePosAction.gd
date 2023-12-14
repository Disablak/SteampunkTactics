class_name SetMovePosAction
extends ActionLeaf

@export var move_pos_type: MovePos = MovePos.NONE

enum MovePos {
	NONE,
	TARGET_UNIT,
	TARGET_UNIT_AROUND_POINT_RANDOM,
}

func tick(actor: Node, blackboard: Blackboard) -> int:
	match move_pos_type:
		MovePos.NONE:
			return FAILURE

		MovePos.TARGET_UNIT:
			var target_enemy: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY) as Unit
			blackboard.set_value(BehaviourAiConst.MOVE_POS, target_enemy.origin_pos)

		MovePos.TARGET_UNIT_AROUND_POINT_RANDOM:
			var points_around_target: Array[Vector2] = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY_AROUND_POINTS)
			blackboard.set_value(BehaviourAiConst.MOVE_POS, points_around_target.pick_random())


	return SUCCESS

