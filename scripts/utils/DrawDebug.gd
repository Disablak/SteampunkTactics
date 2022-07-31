extends ImmediateGeometry

const DRAW_SPHERE = preload("res://scenes/debug/DrawSphere.tscn")

func spheres(points):
	_remove_all()
	
	for p in points:
		var sphere = DRAW_SPHERE.instance()
		add_child(sphere)
		sphere.global_transform.origin = p
		
		sphere.create_sphere(0.3)


func _remove_all():
	for child in get_children():
		child.queue_free()
