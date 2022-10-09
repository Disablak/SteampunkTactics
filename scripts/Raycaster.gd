class_name Raycaster
extends Node3D


const OBSTACLE_MASK = 5


func make_ray_check_no_obstacle(from, to) -> bool:
	var result = make_ray(from, to, OBSTACLE_MASK)
	return result.is_empty()


func make_ray(from, to, collsion_mask) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var ray_query_params := PhysicsRayQueryParameters3D.create(from, to, collsion_mask) #[PhysicalBone3D, CollisionShape3D]
	ray_query_params.collide_with_bodies = false
	ray_query_params.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_query_params)
	return result
