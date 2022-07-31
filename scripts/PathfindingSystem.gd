extends Spatial


export var is_debug := false
export var grid_step := 1.0
export var start_offset := Vector3(0.5, 0, 0.5)

var points := {}
var all_point_position := []
var grid_y := 0.05
var astar := AStar.new()


func _process(delta: float) -> void:
	if not is_debug:
		return
	
	for pos in all_point_position:
		DebugDraw.draw_cube(pos, 0.1)


func _ready() -> void:
	var pathables = get_tree().get_nodes_in_group("pathable")
	_add_points(pathables)
	_remove_obstacle_points()
	_connect_points()


func _add_points(pathables: Array):
	for pathable in pathables:
		var aabb: AABB = _get_aabb_from_pathable(pathable)
		var start_point = aabb.position + start_offset
		
		var x_steps = aabb.size.x / grid_step
		var z_steps = aabb.size.z / grid_step
		
		for x in x_steps:
			for z in z_steps:
				var next_point = start_point + Vector3(x * grid_step, 0, z * grid_step)
				_add_point(next_point)


func _get_aabb_from_pathable(pathable: Node) -> AABB:
	for child in pathable.get_children():
		if child is MeshInstance:
			return child.get_transformed_aabb()
	
	push_error("MeshInstance not found!")
	return AABB();


func _add_point(point: Vector3):
	point.y = grid_y
	var id = astar.get_available_point_id()
	astar.add_point(id, point)
	points[world_to_astar(point)] = id
	all_point_position.append(point)


func _connect_points():
	for point in points:
		var pos_str = point.split(",")
		var world_pos = Vector3(pos_str[0], pos_str[1], pos_str[2])
		var search_cords = [-grid_step, 0, grid_step]
		for x in search_cords:
			for z in search_cords:
				var search_offset = Vector3(x, 0, z)
				if search_offset == Vector3.ZERO:
					continue
				
				var potential_neighbor = world_to_astar(world_pos + search_offset)
				if points.has(potential_neighbor):
					var current_id = points[point]
					var neighbor_id = points[potential_neighbor]
					
					if not astar.are_points_connected(current_id, neighbor_id):
						astar.connect_points(current_id, neighbor_id)


func _remove_obstacle_points():
	var points_to_delete = []
	var obstacles = get_tree().get_nodes_in_group("obstacle")
	for point in points:
		var world_pos := astar_to_world(point)
		for obstacle in obstacles:
			var aabb = obstacle.get_transformed_aabb()
			if aabb.has_point(world_pos):
				astar.remove_point(points[point])
				print("remove ", world_pos)


func find_path(from: Vector3, to: Vector3) -> PoolVector3Array:
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	
	return astar.get_point_path(start_id, end_id)


func world_to_astar(world_point: Vector3) -> String:
	var x = stepify(world_point.x, grid_step)
	var y = stepify(world_point.y, grid_step)
	var z = stepify(world_point.z, grid_step)
	
	return "%d,%d,%d" % [x, y, z]


func astar_to_world(point: String) -> Vector3:
	var pos_str = point.split(",")
	var world_pos = Vector3(pos_str[0], pos_str[1], pos_str[2])
	
	return world_pos
