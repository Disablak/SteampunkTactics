extends Line2D


@export var max_length: int = 50
var point: Vector2
var queue: Array

#
#func _enter_tree() -> void:
	#global_position = Vector2(0, 0)
	#global_rotation = 0


func _process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0

	point = get_parent().global_position
	queue.push_front(point)

	if queue.size() > max_length:
		queue.pop_back()

	clear_points()

	for point in queue:
		add_point(point)
