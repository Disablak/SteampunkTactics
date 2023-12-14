class_name SelectedUnitEffect
extends Node2D


@export var selected_frame: Node2D

var _prev_unit_id := -1


func _ready() -> void:
	GlobalBus.on_unit_changed_control.connect(_on_change_contoll)


func _on_change_contoll(id, instant):
	_try_set_frame_to_prev_unit_pos()

	var unit_pos = GlobalUnits.unit_list.get_unit(id).unit_object.position
	_play_effect(unit_pos)

	_prev_unit_id = id


func _try_set_frame_to_prev_unit_pos():
	if _prev_unit_id >= 0 and GlobalUnits.unit_list.is_unit_exist(_prev_unit_id):
		var prev_unit_pos = GlobalUnits.unit_list.get_unit(_prev_unit_id).unit_object.position
		selected_frame.position = prev_unit_pos


func _play_effect(pos: Vector2):
	selected_frame.modulate = Color(0, 0, 0, 0)

	var tween = create_tween()
	tween.tween_property(selected_frame, "position", pos, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(selected_frame, "modulate", Color.WHITE, 0.1)
	tween.chain().tween_property(selected_frame, "modulate", Color(0, 0, 0, 0), 0.3)
