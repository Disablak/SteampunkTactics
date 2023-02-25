class_name UiUnitInfo
extends Control


@onready var texture_portrait: TextureRect = get_node("TextureRectPortrait")
@onready var lbl_health: Label = get_node("LabelHealth")


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(on_change_unit)
	GlobalBus.on_unit_change_health.connect(on_unit_change_health)


func init():
	on_change_unit(GlobalUnits.cur_unit_id, null)


func on_change_unit(unit_id, _tmp):
	if not GlobalMap.can_show_cur_unit():
		return

	on_unit_change_health(unit_id)


func on_unit_change_health(unit_id):
	if unit_id != GlobalUnits.cur_unit_id:
		return

	if not GlobalMap.can_show_cur_unit():
		return

	var unit: Unit = GlobalUnits.units[unit_id]
	lbl_health.text = "Health {0}/{1}".format([unit.unit_data.cur_health, unit.unit_data.unit_settings.max_health])
