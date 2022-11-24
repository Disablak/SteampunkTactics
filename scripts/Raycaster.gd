class_name Raycaster
extends Node2D


const OBSTACLE_MASK = 5


func make_ray_check_no_obstacle(from, to) -> bool:
	var result = make_ray(from, to, OBSTACLE_MASK)
	if not result.is_empty():
		print("Colliding with {1}/{0}".format([result.collider.name, result.collider.get_parent().name]))
	
	return result.is_empty()


func make_ray(from, to, collsion_mask) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var ray_query_params := PhysicsRayQueryParameters2D.create(from, to, collsion_mask) #[PhysicalBone3D, CollisionShape3D]
	ray_query_params.collide_with_bodies = false
	ray_query_params.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_query_params)
	return result
