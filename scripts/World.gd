class_name World
extends Node3D


@onready var units_controller = get_node("%UnitsController")
@onready var raycaster : Raycaster = get_node("Raycaster")

var all_cover_points : Array[MeshInstance3D] = []
var prev_nearest_cover : Vector3
var best_covers : Array[CoverData] = []
var cur_best_cover : CoverData = null


class CoverData:
	var cover_mesh : MeshInstance3D
	var unit_pos : Vector3
	var pos : Vector3
	var distance_to_unit : float
	var count_visible_enemy : int
	var count_covers_from_enemy : int
	var points : int
	
	func calcPoints() -> int:
		points = 0
		points += (50 - distance_to_unit)
		points += count_visible_enemy * 20
		points += count_covers_from_enemy * 30
		
		print("Points Cover: {0}".format([points]))
		return points



func _ready() -> void:
	for cover in get_tree().get_nodes_in_group("cover_point"):
		all_cover_points.push_back(cover)
	
	GlobalMap.world = self
	GlobalMap.raycaster = raycaster


func find_nearest_cover(unit_pos : Vector3) -> Vector3:
	var cur_nearest_cover_distance : float = 1000
	var nearest_cover : Vector3 = Vector3.ZERO
	
	for cover in all_cover_points:
		var distance : float = cover.global_position.distance_squared_to(unit_pos)
		
		if distance <= cur_nearest_cover_distance:
			cur_nearest_cover_distance = distance
			nearest_cover = cover.global_position
	
	prev_nearest_cover = nearest_cover
	return nearest_cover


func get_best_cover() -> CoverData:
	var unit_pos = Vector3()#GlobalUnits.get_cur_unit().unit_object.global_position
	var covers = find_near_cover_spot(unit_pos, 10)
	var sorted_covers = sort_any_enemy_is_visible_from_cover(covers)
	var best_cover : CoverData = null
	best_covers = sort_covers_realy_can_cover(sorted_covers)
	
	for cover in best_covers:
		cover.calcPoints()
		if best_cover == null or best_cover.points < cover.points:
			best_cover = cover
		
		# Debug
		if cover.count_visible_enemy > 0 && cover.count_covers_from_enemy > 0:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color.GREEN
			cover.cover_mesh.set_surface_override_material(0, mat)
	
	cur_best_cover = best_cover
	return cur_best_cover


func find_near_cover_spot(unit_pos : Vector3, find_distance : float) -> Array[CoverData]:
	var covers : Array[CoverData] = []
	
	for cover in all_cover_points:
		var distance : float = cover.global_position.distance_to(unit_pos)
		
		if distance <= find_distance:
			var cover_data = CoverData.new()
			cover_data.cover_mesh = cover
			cover_data.unit_pos = unit_pos
			cover_data.pos = cover.global_position
			cover_data.distance_to_unit = distance
			covers.append(cover_data)
	
	return covers


func sort_any_enemy_is_visible_from_cover(covers : Array[CoverData]) -> Array[CoverData]:
	var cur_unit : UnitObject = GlobalUnits.get_cur_unit().unit_object
	var enemy_units_ids = GlobalUnits.get_enemy_units_ids()
	
	for enemy_id in enemy_units_ids:
		var enemy_obj : UnitObject = GlobalUnits.units[enemy_id].unit_object
		
		for cover in covers:
			var cover_head_pos : Vector3 = cover.pos
			cover_head_pos.y = cur_unit.shoot_point_node.global_position.y
			var enemy_head_pos : Vector3 = enemy_obj.shoot_point_node.global_position
			#print_debug("ray from {0} to {1}".format([cover_head_pos, enemy_head_pos]))
			
			var is_visible = raycaster.make_ray_check_no_obstacle(cover_head_pos, enemy_head_pos)
			if is_visible:
				cover.count_visible_enemy += 1
	
	return covers


func sort_covers_realy_can_cover(covers : Array[CoverData]) -> Array[CoverData]:
	var enemy_units_ids = GlobalUnits.get_enemy_units_ids()
	var pos_cover_offset = Vector3(0, 0.2, 0)
	
	for enemy_id in enemy_units_ids:
		var enemy_obj : UnitObject = GlobalUnits.units[enemy_id].unit_object
		
		for cover in covers:
			var enemy_pos : Vector3 = Vector3.ZERO#enemy_obj.global_position
			enemy_pos.y = 0.2
			var cover_pos : Vector3 = cover.pos
			cover_pos.y = 0.2
			
			if not raycaster.make_ray_check_no_obstacle(enemy_pos, cover_pos):
				cover.count_covers_from_enemy += 1 
	
	return covers


func _on_BtnMoveUnit_toggled(button_pressed: bool) -> void:
	units_controller.move_unit_mode(button_pressed)


func _on_BtnNextTurn_button_down() -> void:
	units_controller.next_unit()


func _on_btn_unit_aim_toggled(button_pressed: bool) -> void:
	units_controller.shoot_unit_mode(button_pressed)
