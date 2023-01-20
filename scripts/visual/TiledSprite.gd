@tool
extends Sprite2D


func _ready():
	set_notify_transform(true)


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		get_material().set_shader_parameter("scale_factor", scale)
