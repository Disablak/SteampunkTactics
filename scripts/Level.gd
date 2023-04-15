class_name Level
extends Node2D


@onready var root_obstacles = $RootObsCells
@onready var root_units = $RootUnits
@onready var ground_plate = $RootWalkCells/Ground
@export var roof_zones_path = {} # node path zone / node path parent of root cells


var map_size: Vector2:
	get: return get_node("RootWalkCells").get_node("Ground").scale

var all_sorted_objects = []
var prev_transparent_objs = []
var cur_pointer_cell_pos: Vector2
var dict_roof_pos_and_roof = {}
var dict_pos_and_roof = {}


func update_roof_visibility():
	for roof_poses in dict_roof_pos_and_roof:
		var roof_object = dict_roof_pos_and_roof[roof_poses]
		roof_object.visible = true

	for unit_id in GlobalUnits.units:
		var unit_pos = GlobalUnits.units[unit_id].unit_object.grid_pos
		for roof_poses in dict_roof_pos_and_roof:
			var roof_object = dict_roof_pos_and_roof[roof_poses]
			if roof_poses.has(unit_pos) and GlobalMap.can_show_unit(unit_id):
				roof_object.visible = false


func is_roof_exist_and_visible(grid_pos) -> bool:
	return dict_pos_and_roof.has(grid_pos) and dict_pos_and_roof[grid_pos].is_visible_in_tree()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)
	GlobalBus.on_hovered_cell.connect(_on_hovered_cell)
	GlobalBus.on_unit_moved_to_another_cell.connect(_on_unit_moved_to_another_cell)

	ground_plate.visible = false

	for child in root_obstacles.get_children():
		all_sorted_objects.append(child)

	for child in root_units.get_children():
		all_sorted_objects.append(child)

	for roof_path in roof_zones_path:
		var node_roof_zone = get_node(roof_path)
		var cells_in_zone = Globals.get_cells_by_node2d(node_roof_zone)
		var parent_of_roofs = get_node(roof_zones_path[roof_path])
		dict_roof_pos_and_roof[cells_in_zone] = parent_of_roofs

		for roof in parent_of_roofs.get_children():
			dict_pos_and_roof[Globals.convert_to_grid_pos(roof.position)] = roof


	await get_tree().process_frame
	_update_visual()


func _process(delta: float) -> void:
	if GlobalUnits.units_manager.walking.is_unit_moving():
		_update_visual()


func _on_unit_died(id, killer):
	_update_visual()


func _on_unit_moved_to_another_cell(unit_id, cell_pos):
	update_roof_visibility()


func _update_visual():
	_update_ordering()
	_update_transparency()


func _update_ordering():
	all_sorted_objects.sort_custom(_sort_ascending)
	GlobalMap.draw_debug.clear_points_ordering()

	var i = 1
	var prev_obj
	for obj in all_sorted_objects:
		if not obj:
			continue

		var same_origin_pos = prev_obj and prev_obj.origin_pos.y == obj.origin_pos.y
		obj.visual_ordering = prev_obj.visual_ordering if same_origin_pos else i
		prev_obj = obj

		if not same_origin_pos:
			i += 1

		GlobalMap.draw_debug.draw_object_order_point(obj.origin_pos, obj.visual_ordering)

	for roof_parent in dict_roof_pos_and_roof.values():
		for roof in roof_parent.get_children():
			GlobalMap.draw_debug.draw_object_order_point(roof.origin_pos, 50)


func _sort_ascending(a, b):
	if not a or not b:
		return false

	return a.origin_pos.y < b.origin_pos.y


func _update_transparency():
	for prev in prev_transparent_objs:
		prev.make_transparent(false)

	prev_transparent_objs.clear()

	var units = GlobalUnits.units.values()
	for unit in units:
		for obj in all_sorted_objects:
			if obj == null or obj is UnitObject:
				continue

			if _can_hide(unit.unit_object.origin_pos, obj.origin_pos):
				prev_transparent_objs.append(obj)
				obj.make_transparent(true)

		for roof_parent in dict_roof_pos_and_roof.values():
			var root_node: Node2D = roof_parent as Node2D
			for roof in roof_parent.get_children():
				if unit.unit_object.origin_pos.distance_to(roof.origin_pos) <= 26: # todo magic number
					prev_transparent_objs.append(roof)
					roof.make_transparent(true)


	for obj in all_sorted_objects:
		if obj == null or obj is UnitObject:
				continue

		if _can_hide(cur_pointer_cell_pos, obj.origin_pos):
			prev_transparent_objs.append(obj)
			obj.make_transparent(true)

	for roof_parent in dict_roof_pos_and_roof.values():
		for roof in roof_parent.get_children():
			if cur_pointer_cell_pos.distance_to(roof.origin_pos) <= 8: # todo magic number
				prev_transparent_objs.append(roof)
				roof.make_transparent(true)


func _can_hide(unit_pos: Vector2, obj_pos: Vector2) -> bool:
	if obj_pos.y < unit_pos.y:
		return false

	if abs(obj_pos.y - unit_pos.y) > 16:
		return false

	if abs(obj_pos.x - unit_pos.x) > 6:
		return false

	return true


func _on_hovered_cell(cell_info: CellInfo):
	cur_pointer_cell_pos = Globals.convert_to_cell_pos(cell_info.grid_pos) + Globals.CELL_OFFSET
	cur_pointer_cell_pos.y += 2
	_update_transparency()
