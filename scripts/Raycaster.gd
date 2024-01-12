class_name Raycaster
extends Node2D


@export var segment_shape_2d: SegmentShape2D

const LAYER_1 := 0xFFFFFFFF
const MASK_WALL = 16
const MASK_OBSTACLE = 32
const REFLECT_COLLISION_GROUP = "collision_reflect"


func get_shoot_data(pos: Vector2, dir: Vector2, max_distance: float, collsion_mask: int = LAYER_1, exlude: Array[RID] = []) -> ShootData:
	var shoot_data = ShootData.new()
	shoot_data.shoot_points.append(ShootData.ShootPoint.new(pos, null))

	var ray_end: Vector2 = pos + (dir * max_distance)
	var start_ray: Dictionary = make_ray(pos, ray_end, collsion_mask, exlude)
	if not start_ray.is_empty():
		if start_ray.collider.is_in_group(REFLECT_COLLISION_GROUP):
			var game_object: GameObject = start_ray.collider.get_parent() as GameObject
			shoot_data.shoot_points.append(ShootData.ShootPoint.new(start_ray.position, game_object))
			exlude.append(game_object.get_this_exclude_rid())

			var dir_to_start = (pos - start_ray.position).normalized()
			var dir_reflect: Vector2 = dir_to_start.reflect(start_ray.normal)
			var distance_remains: float = max_distance - pos.distance_to(start_ray.position)
			var reflect_end_pos: Vector2 = start_ray.position + (dir_reflect * distance_remains)
			var reflect_ray: Dictionary = make_ray(start_ray.position, reflect_end_pos, collsion_mask, exlude)

			if reflect_ray.is_empty():
				shoot_data.shoot_points.append(ShootData.ShootPoint.new(reflect_end_pos, null))
			else:
				shoot_data.shoot_points.append(ShootData.ShootPoint.new(reflect_ray.position, reflect_ray.collider.get_parent()))
		else:
			shoot_data.shoot_points.append(ShootData.ShootPoint.new(start_ray.position, start_ray.collider.get_parent()))
	else:
		shoot_data.shoot_points.append(ShootData.ShootPoint.new(ray_end, null))

	return shoot_data


func make_ray_get_units(from: Vector2, to: Vector2) -> Array[UnitObject]:
	var intersections: Array[Dictionary] = make_ray_intersections(from, to)
	var result: Array[UnitObject]

	for intersection in intersections:
		if intersection.is_empty():
			continue

		var unit_object: UnitObject = intersection.collider.get_parent() as UnitObject
		if unit_object:
			result.append(unit_object)

	return result


func make_ray_get_obstacles(from, to) -> Array[CellObject]:
	var covers: Array[CellObject] = []

	var result: Array[Dictionary] = make_ray_intersections(from, to)

	for res in result:
		if not res.is_empty():
			if res.collider.get_parent() is CellObject:
				covers.append(res.collider.get_parent())
				printerr("ray obstacle {0}".format([res.collider.get_parent().name]))

	return covers


func make_ray_get_obs(from, to):
	var result := make_ray_get_obstacles(from, to)
	return Globals.get_cells_of_type(result, CellObject.CellType.OBSTACLE)


func make_ray_check_no_obstacle(from, to, mask: int = MASK_WALL) -> bool:
	var result = make_ray(from, to, mask)
	if not result.is_empty():
		print("Colliding with {1}/{0}".format([result.collider.name, result.collider.get_parent().name]))

	return result.is_empty()


func make_ray_and_get_positions(pos_from: Vector2, pos_to: Vector2, show_line_to_obstacle = false) -> Array[Vector2]:
	var ray_result = make_ray(pos_from, pos_to, MASK_WALL)

	if ray_result.is_empty():
		return [pos_from, pos_to]
	elif show_line_to_obstacle:
		return [pos_from, ray_result.position]
	else:
		return []


func make_ray_and_get_collision_point(pos_from: Vector2, pos_to: Vector2, collsion_mask: int, exlude: Array[RID] = []) -> Vector2:
	var result = make_ray(pos_from, pos_to, collsion_mask, exlude)
	if result.is_empty():
		return pos_to

	return result.position


func make_ray_with_excludes(from, to, exclude: Array[RID]):
	return make_ray(from, to, LAYER_1, exclude)


func make_ray(from: Vector2, to: Vector2, collsion_mask: int = LAYER_1, exlude: Array[RID] = []) -> Dictionary:
	var ray_query_params := PhysicsRayQueryParameters2D.create(from, to, collsion_mask, exlude)
	ray_query_params.collide_with_bodies = true
	ray_query_params.collide_with_areas = true

	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_ray(ray_query_params)


func make_ray_intersections(from, to) -> Array[Dictionary]:
	segment_shape_2d.a = from
	segment_shape_2d.b = to

	var shape_query_params := PhysicsShapeQueryParameters2D.new()
	shape_query_params.shape = segment_shape_2d
	#shape_query_params.collision_mask = MASK_OBSTACLE

	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_shape(shape_query_params)
