extends Spatial


export var is_debug := false

var cur_shoot_point
var cur_target_points: PoolVector3Array

func _process(delta: float) -> void:
	if not is_debug or cur_target_points == null or cur_target_points.size() == 0:
		return
	
	for point in cur_target_points:
		DebugDraw.draw_line_3d(cur_shoot_point, point, Color.white)


func shoot(shoot_point: Vector3, target_points: PoolVector3Array) -> int:
	self.cur_shoot_point = shoot_point
	cur_target_points = PoolVector3Array()
	
	var count_hitted = 0
	
	for point in target_points:
		var ray_result = _make_ray(shoot_point, point)
		var target_pos = ray_result.position if ray_result else point
		cur_target_points.push_back(target_pos)
		if not ray_result:
			count_hitted += 1
		elif is_debug:
			print(ray_result)
	
	if is_debug:
		print("hitted {0} / {1}".format([count_hitted, target_points.size()]))
	
	return count_hitted


func _make_ray(from, to):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [PhysicalBone, CollisionShape], 5, false, true)
	return result
