extends Spatial


onready var label_health = get_node("Label3DHealth")
onready var label_walk_distance = get_node("Label3DWalkDistance")


func _ready() -> void:
	pass


func update_health(cur_health, max_health):
	label_health.text = "HP: {0}/{1}".format([cur_health, max_health])

func update_walk_distance(cur_distance, max_distance):
	label_walk_distance.text = "Distance: {0}".format(["%0.2f" % cur_distance])
