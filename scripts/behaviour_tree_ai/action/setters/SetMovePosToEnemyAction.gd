class_name SetMovePosToEnemyAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var is_iam_enemy := (actor as UnitObject).is_enemy
	var first_enemy_unit: Unit = GlobalUnits.unit_list.get_team_units(!is_iam_enemy)[0]

	blackboard.set_value("move_pos", first_enemy_unit.unit_object.position)

	return SUCCESS

