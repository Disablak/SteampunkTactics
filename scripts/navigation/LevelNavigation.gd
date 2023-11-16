extends Node2D

@export var camera: Camera2D
@export var navigation_region_generator: NavigationRegionGenerator
@export var collision_battleground: CollisionPolygon2D
@export var object_selector: ObjectsSelector
@export var player: Node2D
@export var line2d_manager: Line2dManager

var target_pos: Vector2

func _ready() -> void:
	object_selector.inject_data(camera)

	await get_tree().physics_frame
	await get_tree().process_frame
	_generate_nav_mesh()


func _generate_nav_mesh():
	var all_collision_polygones = get_tree().get_nodes_in_group("collision_obstacle")
	var array_all_collision_polygones: Array[CollisionPolygon2D]
	array_all_collision_polygones.assign(all_collision_polygones)
	navigation_region_generator.update_nav_region(collision_battleground, array_all_collision_polygones)


func _find_path(pos: Vector2):
	var maps = NavigationServer2D.get_maps()
	var map0 = maps[0]
	var from = Vector2(20, 26)
	var formatted_pos_from = NavigationServer2D.map_get_closest_point(map0, from)
	var formatted_pos_to = NavigationServer2D.map_get_closest_point(map0, pos)
	var path = NavigationServer2D.map_get_path(map0, formatted_pos_from, formatted_pos_to, true)
	var path_array: Array[Vector2]
	path_array.assign(Array(path))
	line2d_manager.clear_path()
	line2d_manager.draw_path_without_offset(path_array, false)


func _on_objects_selector_on_click_on_object(click_pos, objects) -> void:
	_find_path(click_pos)
