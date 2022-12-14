extends Control


@onready var btn_next_turn: Button = get_node("%BtnNextTurn")
@onready var label_ammo: Label = get_node("%LabelAmmo")
@onready var pointer = get_node("%Pointer")
@onready var btn_granade: Button = get_node("%BtnGranade") as Button


func _ready() -> void:
	GlobalBus.on_unit_changed_ammo.connect(_on_unit_changed_ammo)
	GlobalBus.on_unit_changed_control.connect(_update_unit_ammo)

	_update_unit_ammo(-1, false)


func _update_unit_ammo(unit_id, instantly):
	var cur_unit_data: UnitData = GlobalUnits.get_cur_unit().unit_data
	_on_unit_changed_ammo(cur_unit_data.unit_id, cur_unit_data.cur_weapon_ammo, cur_unit_data.weapon.ammo)


func _on_unit_changed_ammo(unit_id, cur_ammo, max_ammo):
	if unit_id != GlobalUnits.cur_unit_id:
		return

	label_ammo.text = "Ammo: {0}/{1}".format([cur_ammo, max_ammo])


func _on_input_system_on_mouse_hover(hover_info) -> void:
	pointer.position = hover_info.cell_pos
