class_name EndTurnAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("end turn")
	GlobalUnits.unit_order.next_unit_turn()
	return SUCCESS

