tool
extends Spatial


export var is_debug := false setget _set_debug_mode, _get_debug_mode
export var update_astar = false setget _update_astar

export var grid_size := Vector2(10, 10)
export var start_offset := Vector2(0, 0)

var grid_step := 1.0

onready var pathfinding_debug := $PathfindingDebug

var points := {}
var astar := AStar.new()

const grid_y := 0.05


func _set_debug_mode(debug):
	is_debug = debug
	if pathfinding_debug:
		pathfinding_debug.visible = debug

func _get_debug_mode():
	return is_debug


func _update_astar(update):
	_create_pathfinding()


func _ready() -> void:
	_create_pathfinding()


func _create_pathfinding():
	points = {}
	astar = AStar.new()
	
	var pathables = get_tree().get_nodes_in_group("pathable")
	_add_points(pathables)
	_remove_obstacle_points()
	_connect_points()

	if is_debug:
		var all_points = PoolVector3Array()
		for point_pos in points.keys():
			var pos = astar_to_world(point_pos)
			pos = Vector3(pos.x, grid_y, pos.z)
			all_points.push_back(pos)
		
		
		pathfinding_debug.draw_squares(all_points)


func _add_points(pathables: Array):
	var x_steps = stepify(grid_size.x, grid_step)
	var z_steps = stepify(grid_size.y, grid_step)
	var offset = Vector3(start_offset.x, 0, start_offset.y)
	
	for x in x_steps:
		for z in z_steps:
			var next_point = offset + Vector3(x * grid_step, 0, z * grid_step)
			_add_point(next_point)


func _add_point(point: Vector3):
	point.y = grid_y
	var id = astar.get_available_point_id()
	astar.add_point(id, point)
	points[world_to_astar(point)] = id


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
	var obstacles = get_tree().get_nodes_in_group("obstacle")
	for str_point_world_pos in points.keys():
		var world_pos := astar_to_world(str_point_world_pos)
		for obstacle in obstacles:
			var aabb = obstacle.get_transformed_aabb()
			if aabb.has_point(world_pos):
				print("remove ", points[str_point_world_pos], world_pos)
				astar.remove_point(points[str_point_world_pos])
				points.erase(str_point_world_pos)


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
