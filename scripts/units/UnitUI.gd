extends Spatial


func _ready() -> void:
	pass


func update_health(cur_health, max_health):
	print("update health")
	$Health/Viewport/Label.text = "{0}/{1}".format([cur_health, max_health])
