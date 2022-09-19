extends Marker3D

@export var drag_sensitive = 0.02
@export var camera_offset = Vector3.ZERO
@export var focus_time = 0.2

var rot = Quaternion(Vector3.UP, -45).normalized()

var tween_move: Tween


func _init():
	GlobalBus.connect(GlobalBus.on_setted_unit_control_name,Callable(self,"focus_camera"))


func _on_input_system_on_drag(dir) -> void:
	global_transform.origin += rot * (Vector3(dir.x, 0.0, dir.y) * drag_sensitive)


func focus_camera(target_spatial: Node3D, instantly: bool = false):
	var target_pos: Vector3 = target_spatial.global_transform.origin + camera_offset
	target_pos.y = global_transform.origin.y
	
	if instantly:
		global_transform.origin = target_pos
		return
	
	tween_move = create_tween()
	tween_move.set_trans(Tween.TRANS_SINE)
	tween_move.tween_property(
		self,
		"position",
		target_pos,
		focus_time if not instantly else 0.0
	)
