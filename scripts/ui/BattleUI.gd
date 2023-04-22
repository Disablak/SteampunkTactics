extends Control


@onready var label_fps: Label = get_node("%LabelFPS")
@onready var label_is_enemy_turn = $AlwaysUI/LabelIsEnemyTurn

@onready var btn_next_turn: Button = get_node("%BtnNextTurn")

@onready var btn_zoom_100: Button = %BtnZoom100
@onready var btn_zoom_150: Button = %BtnZoom150
@onready var btn_zoom_200: Button = %BtnZoom200

@onready var unit_info: UiUnitInfo = get_node("%UnitInfo") as UiUnitInfo
@onready var unit_abilities: UiUnitAbilities = get_node("%UnitAbils") as UiUnitAbilities
@onready var units_list: UiUnitsList = get_node("%UnitsList") as UiUnitsList
@onready var panel_unit_info: UiSelectedUnitInfo = get_node("%PanelUnitInfo")


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_unit_change_control)

	btn_zoom_100.pressed.connect(func(): _change_camera_zoom(2))
	btn_zoom_150.pressed.connect(func(): _change_camera_zoom(1.5))
	btn_zoom_200.pressed.connect(func(): _change_camera_zoom(1))
	btn_next_turn.pressed.connect(func(): GlobalBus.on_clicked_next_turn.emit())


func _process(_delta: float) -> void:
	label_fps.text = "{0}".format([Engine.get_frames_per_second()])


func init():
	_on_unit_change_control(-1, false)

	unit_info.init()
	unit_abilities.init(GlobalUnits.get_cur_unit().unit_data)
	units_list.init(TurnManager.order_unit_id)
	panel_unit_info.init()


func _change_camera_zoom(zoom: float):
	GlobalBus.on_change_camera_zoom.emit(zoom)


func _on_unit_change_control(unit_id, _instantly):
	var unit: Unit = GlobalUnits.get_cur_unit()
	if not unit:
		return

	var can_show_cur_unit = GlobalMap.can_show_cur_unit()
	var show_label_enemys_turn = unit.unit_data.is_enemy and not can_show_cur_unit
	label_is_enemy_turn.visible = show_label_enemys_turn

	if not can_show_cur_unit:
		return

	unit_abilities.init(unit.unit_data)

