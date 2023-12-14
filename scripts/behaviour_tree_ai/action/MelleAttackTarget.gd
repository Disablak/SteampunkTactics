class_name MelleAttackTarget
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var unit: Unit = GlobalUnits.unit_list.get_unit((actor as UnitObject).unit_id)
	var target_enemy: Unit = blackboard.get_value(BehaviourAiConst.TARGET_ENEMY) as Unit
	var melee_attack_contoll: MelleeAttackControll = GlobalUnits.unit_control.melle_attack_controll

	if melee_attack_contoll.can_attack(unit, target_enemy):
		melee_attack_contoll.attack(unit, target_enemy)
		return SUCCESS

	return FAILURE

