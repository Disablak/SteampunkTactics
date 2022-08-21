extends Spatial


export var unit_size := 0.9
export var grid_size := 1.0


func get_simple_path(astar_points: PoolVector3Array) -> PoolVector3Array:
	if astar_points.size() <= 2:
		return astar_points
	
	var points_result = []
	points_result.push_back(astar_points[0])
	
	var control_point_idx = 0
	var control_point = astar_points[control_point_idx]
	var current_point = control_point
	var size = astar_points.size()
	var target_point = astar_points[size - 1]
	
	while(points_result[points_result.size() - 1] != target_point):
		current_point = control_point
		
		for j in range(control_point_idx, size):
			if not raycast(astar_points[control_point_idx], astar_points[j]): # no obstacles
				current_point = astar_points[j]
			else:
				control_point = current_point
				control_point_idx = j - 1 # prev
				break
		
		points_result.push_back(current_point)
	
	return points_result


func raycast(from, to) -> bool:
	var start = Vector3(from.x, 0.5, from.z)
	var end = Vector3(to.x, 0.5, to.z)
	
	var direct_state = get_world().direct_space_state
	var collision = direct_state.intersect_ray(start, end, [], 5, false, true)
	#print("ray ", start, " and ", end, " result: ", collision)
	
	return not collision.empty()
