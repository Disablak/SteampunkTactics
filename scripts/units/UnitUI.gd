extends Spatial


onready var label_health = get_node("Label3DHealth")


func _ready() -> void:
	pass


func update_health(cur_health, max_health):
	label_health.text = "{0}/{1}".format([cur_health, max_health])
