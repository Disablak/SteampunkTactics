class_name EndTurnAction
extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("end turn")
	GlobalUnits.unit_control.next_turn()
	return SUCCESS

