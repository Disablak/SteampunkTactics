class_name Raycaster
extends Node2D


@export var segment_shape_2d: SegmentShape2D

const OBSTACLE_MASK = 16 #  0b0101 #5
const COVER_MASK = 32


func make_ray_check_covers(from, to) -> Array[CellObject]:
	var covers: Array[CellObject]

	var result: Array[Dictionary] = make_ray_intersections(from, to)

	for res in result:
		if not res.is_empty():
			if res.collider.get_parent() is CellObject:
				covers.append(res.collider.get_parent())
				printerr(res.collider.get_parent().name)

	return covers


func make_ray_check_no_obstacle(from, to) -> bool:
	var result = make_ray(from, to, OBSTACLE_MASK)
	if not result.is_empty():
		print("Colliding with {1}/{0}".format([result.collider.name, result.collider.get_parent().name]))

	return result.is_empty()


func make_ray_and_get_positions(pos_from: Vector2, pos_to: Vector2, show_line_to_obstacle = false) -> PackedVector2Array:
	var ray_result = make_ray(pos_from, pos_to, OBSTACLE_MASK)

	if ray_result.is_empty():
		var result = PackedVector2Array()
		result.push_back(pos_from)
		result.push_back(pos_to)
		return result
	elif show_line_to_obstacle:
		return PackedVector2Array([pos_from, ray_result.position])
	else:
		return PackedVector2Array()


func make_ray_and_get_collision_point(pos_from: Vector2, pos_to: Vector2, collsion_mask) -> Vector2:
	var result = make_ray(pos_from, pos_to, collsion_mask)
	if result.is_empty():
		return Vector2.ZERO

	return result.position


func make_ray(from, to, collsion_mask) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var ray_query_params := PhysicsRayQueryParameters2D.create(from, to, collsion_mask)
	ray_query_params.collide_with_bodies = true
	ray_query_params.collide_with_areas = true

	return space_state.intersect_ray(ray_query_params)


func make_ray_intersections(from, to) -> Array[Dictionary]:
	segment_shape_2d.a = from
	segment_shape_2d.b = to

	var space_state = get_world_2d().direct_space_state
	var shape_query_params := PhysicsShapeQueryParameters2D.new()
#
#	shape_query_params.collide_with_bodies = true
#	shape_query_params.collide_with_areas = true
	shape_query_params.shape = segment_shape_2d
	shape_query_params.collision_mask = COVER_MASK

	return space_state.intersect_shape(shape_query_params)
