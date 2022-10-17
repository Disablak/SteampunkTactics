extends Node2D

@export var drag_sensitive = 0.02
@export var camera_offset = Vector2.ZERO
@export var focus_time = 0.2

var rot = Quaternion(Vector3.UP, -45).normalized()

var tween_move: Tween


func _init():
	#GlobalBus.connect(GlobalBus.on_setted_unit_control_name,Callable(self,"focus_camera"))
	pass


func _on_input_system_on_drag(dir) -> void:
	global_transform.origin += rot * (Vector3(dir.x, 0.0, dir.y) * drag_sensitive)


func focus_camera(target: Node2D, instantly: bool = false):
	pass
	var target_pos: Vector2 = target.global_transform.origin + camera_offset
	target_pos.y = global_transform.origin.y
	
	if instantly:
		position = target_pos
		return
	
	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		focus_time if not instantly else 0.0
	)
