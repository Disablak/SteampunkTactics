class_name UiUnitInfo
extends Control


@onready var texture_portrait: TextureRect = get_node("TextureRectPortrait")
@onready var lbl_health: Label = get_node("LabelHealth")


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(on_change_unit)
	GlobalBus.on_unit_change_health.connect(on_unit_change_health)
	GlobalBus.on_unit_stat_changed.connect(_on_unit_stat_changed)


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

	var txt_health: String = "Health {0}/{1}".format([unit.unit_data.cur_health, unit.unit_data.max_health])

	var txt_armor: String
	if unit.unit_data.cur_armor > 0:
		txt_armor = "Armor {0}".format([unit.unit_data.cur_armor])

	lbl_health.text = "{0}\n{1}".format([txt_health, txt_armor])


func _on_unit_stat_changed(unit_id: int, stat: UnitStat):
	on_unit_change_health(unit_id)
