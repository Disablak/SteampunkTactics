class_name IfEnemyWithinRangeCondition
extends IfTargetPosWithinRangeCondition


func before_run(actor: Node, blackboard: Blackboard):
	var is_iam_enemy := (actor as UnitObject).is_enemy
	var first_enemy_unit: Unit = GlobalUnits.unit_list.get_team_units(!is_iam_enemy)[0]
	target_pos = first_enemy_unit.unit_object.position
	range = 50.0

	blackboard.set_value("move_pos", target_pos)

