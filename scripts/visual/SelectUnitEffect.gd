class_name SelectedUnitEffect
extends RefCounted


var _selected_frame: Node2D


func _init(selected_frame: Node2D):
	_selected_frame = selected_frame


func play_effect(tween: Tween, pos: Vector2):
	_selected_frame.modulate = Color(0, 0, 0, 0)

	tween.tween_property(_selected_frame, "position", pos, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(_selected_frame, "modulate", Color.WHITE, 0.1)
	tween.chain().tween_property(_selected_frame, "modulate", Color(0, 0, 0, 0), 0.3)
