extends Control


@onready var label_fps: Label = get_node("%LabelFPS")

@onready var btn_next_turn: Button = get_node("%BtnNextTurn")
@onready var btn_shoot: Button = get_node("%BtnShoot")
@onready var pointer = get_node("%Pointer")
@onready var btn_granade: Button = get_node("%BtnGranade") as Button
@onready var units_list: UiUnitsList = get_node("%UnitsList") as UiUnitsList


func _ready() -> void:
	GlobalBus.on_unit_changed_ammo.connect(_on_unit_changed_ammo)
	GlobalBus.on_unit_changed_control.connect(_update_unit_ammo)


func _process(delta: float) -> void:
	label_fps.text = "{0}".format([Engine.get_frames_per_second()])


func init():
	_update_unit_ammo(-1, false)

	units_list.init(TurnManager.order_unit_id)


func _update_unit_ammo(unit_id, instantly):
	var cur_unit_data: UnitData = GlobalUnits.get_cur_unit().unit_data
	_on_unit_changed_ammo(cur_unit_data.unit_id, cur_unit_data.cur_weapon_ammo, cur_unit_data.weapon.ammo)


func _on_unit_changed_ammo(unit_id, cur_ammo, max_ammo):
	if unit_id != GlobalUnits.cur_unit_id:
		return

	btn_shoot.text = "Shoot ({0}/{1})".format([cur_ammo, max_ammo])


func _on_input_system_on_mouse_hover(mouse_pos) -> void:
	pointer.position = mouse_pos
