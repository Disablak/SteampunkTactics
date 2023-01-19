extends Control


@onready var label_fps: Label = get_node("%LabelFPS")
@onready var pointer = get_node("%Pointer")

@onready var btn_shoot: Button = get_node("%BtnShoot")

@onready var btn_zoom_100: Button = %BtnZoom100
@onready var btn_zoom_150: Button = %BtnZoom150
@onready var btn_zoom_200: Button = %BtnZoom200

@onready var unit_info: UiUnitInfo = get_node("%UnitInfo") as UiUnitInfo
@onready var unit_abilities: UiUnitAbilities = get_node("%UnitAbils") as UiUnitAbilities
@onready var units_list: UiUnitsList = get_node("%UnitsList") as UiUnitsList
@onready var selected_unit_info: UiSelectedUnitInfo = get_node("%SelectedUnitInfo")


func _ready() -> void:
	GlobalBus.on_unit_changed_ammo.connect(_on_unit_changed_ammo)
	GlobalBus.on_unit_changed_control.connect(_on_unit_change_control)

	btn_zoom_100.pressed.connect(func(): _change_camera_zoom(2))
	btn_zoom_150.pressed.connect(func(): _change_camera_zoom(1.5))
	btn_zoom_200.pressed.connect(func(): _change_camera_zoom(1))


func _process(delta: float) -> void:
	label_fps.text = "{0}".format([Engine.get_frames_per_second()])


func init():
	_on_unit_change_control(-1, false)

	unit_info.init()
	unit_abilities.init(GlobalUnits.get_cur_unit().unit_data)
	units_list.init(TurnManager.order_unit_id)
	selected_unit_info.init()


func _change_camera_zoom(zoom: float):
	GlobalBus.on_change_camera_zoom.emit(zoom)


func _on_unit_change_control(unit_id, instantly):
	var cur_unit_data: UnitData = GlobalUnits.get_cur_unit().unit_data
	_on_unit_changed_ammo(cur_unit_data.unit_id, cur_unit_data.cur_weapon_ammo, cur_unit_data.weapon.ammo)

	unit_abilities.init(GlobalUnits.get_cur_unit().unit_data)


func _on_unit_changed_ammo(unit_id, cur_ammo, max_ammo):
	if unit_id != GlobalUnits.cur_unit_id:
		return

	btn_shoot.text = "Shoot ({0}/{1})".format([cur_ammo, max_ammo])


func _on_input_system_on_mouse_hover(mouse_pos) -> void:
	pointer.position = mouse_pos
