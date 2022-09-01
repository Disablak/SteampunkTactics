extends Control


onready var btn_move_unit: Button = get_node("%BtnMoveUnit")
onready var btn_aim_unit: Button = get_node("%BtnUnitAim")
onready var btn_next_turn: Button = get_node("%BtnNextTurn")

func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_changed_action_name, self, "_on_unit_change_action")


func _on_unit_change_action(unit_id, action_type):
	#print(Globals.UnitAction.keys()[action_type])

	match action_type:
		Globals.UnitAction.SHOOT:
			btn_move_unit.pressed = false

		Globals.UnitAction.WALK:
			btn_aim_unit.pressed = false

