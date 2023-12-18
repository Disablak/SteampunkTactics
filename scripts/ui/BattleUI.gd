extends Control


@onready var label_fps: Label = get_node("%LabelFPS")
@onready var label_is_enemy_turn = $LabelIsEnemyTurn

@onready var btn_next_turn: Button = get_node("%BtnNextTurn")

@onready var btn_zoom_100: Button = %BtnZoom100
@onready var btn_zoom_150: Button = %BtnZoom150
@onready var btn_zoom_200: Button = %BtnZoom200

@onready var unit_info: UiUnitInfo = get_node("%UnitInfo") as UiUnitInfo
@onready var units_list: UiUnitsList = get_node("%UnitsList") as UiUnitsList
@onready var panel_unit_info: UiSelectedUnitInfo = get_node("%PanelUnitInfo")


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_change_control)

	btn_zoom_100.pressed.connect(func(): _change_camera_zoom(2))
	btn_zoom_150.pressed.connect(func(): _change_camera_zoom(1.5))
	btn_zoom_200.pressed.connect(func(): _change_camera_zoom(1))
	btn_next_turn.pressed.connect(_next_turn)


func _process(_delta: float) -> void:
	label_fps.text = "{0}".format([Engine.get_frames_per_second()])


func init():
	_update_label_enemys_turn(GlobalUnits.unit_list.get_cur_unit_id())

	unit_info.init()
	units_list.init(GlobalUnits.unit_order.ordered_unit_ids)
	panel_unit_info.init()


func _change_camera_zoom(zoom: float):
	GlobalBus.on_change_camera_zoom.emit(zoom)


func _next_turn():
	GlobalUnits.unit_order.next_unit_turn()


func _on_unit_change_control(unit_id: int, instantly: bool):
	_update_label_enemys_turn(unit_id)


func _update_label_enemys_turn(unit_id: int):
	var unit: Unit = GlobalUnits.unit_list.get_unit(unit_id)
	var show_label_enemys_turn = unit.unit_data.is_enemy
	label_is_enemy_turn.visible = show_label_enemys_turn
