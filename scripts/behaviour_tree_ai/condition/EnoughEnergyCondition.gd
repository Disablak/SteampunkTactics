class_name EnoughEnergyCondition
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var energy_price: int = blackboard.get_value("energy_price")
	if TurnManager.can_spend_time_points(energy_price):
		return SUCCESS
	else:
		return FAILURE

