extends Position3D

export var drag_sensitive = 0.02
var rot = Quat(Vector3.UP, -45).normalized()



func _on_InputSystem_on_drag(dir) -> void:
	global_transform.origin += rot * (Vector3(dir.x, 0.0, dir.y) * drag_sensitive)
