extends Area


var min_vec
var max_vec

func _enter_tree() -> void:
	var global_pos = global_transform.origin
	var collision: CollisionShape = get_child(0)
	var shape_extends = collision.shape.get_extents()
	min_vec = Vector2(global_pos.x - shape_extends.x, global_pos.z - shape_extends.z)
	max_vec = Vector2(global_pos.x + shape_extends.x, global_pos.z + shape_extends.z)
	print( "obstacle min:{0}, max:{1}".format([min_vec, max_vec]))


func is_point_in_shape(point: Vector3):
	return (point.x >= min_vec.x and point.x <= max_vec.x) and (point.z >= min_vec.y and point.z <= max_vec.y)
