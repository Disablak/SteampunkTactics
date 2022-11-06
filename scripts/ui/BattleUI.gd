extends Control


@onready var btn_move_unit: Button = get_node("%BtnMoveUnit")
@onready var btn_aim_unit: Button = get_node("%BtnUnitAim")
@onready var btn_next_turn: Button = get_node("%BtnNextTurn")
@onready var label_ammo: Label = get_node("LabelAmmo")


func _ready() -> void:
	GlobalBus.on_unit_changed_action.connect(_on_unit_change_action)
	GlobalBus.on_unit_changed_ammo.connect(_on_unit_changed_ammo)
	GlobalBus.on_setted_unit_control.connect(_update_unit_ammo)

	_update_unit_ammo(-1, false)


func _update_unit_ammo(unit_id, instantly):
	var cur_unit_data: UnitData = GlobalUnits.get_cur_unit().unit_data
	_on_unit_changed_ammo(cur_unit_data.unit_id, cur_unit_data.cur_weapon_ammo, cur_unit_data.weapon.ammo)


func _on_unit_change_action(unit_id, action_type):
	#print(Globals.UnitAction.keys()[action_type])

	match action_type:
		Globals.UnitAction.SHOOT:
			btn_move_unit.button_pressed = false

		Globals.UnitAction.WALK:
			btn_aim_unit.button_pressed = false


func _on_unit_changed_ammo(unit_id, cur_ammo, max_ammo):
	if unit_id != GlobalUnits.cur_unit_id:
		return
	
	label_ammo.text = "Ammo: {0}/{1}".format([cur_ammo, max_ammo])
