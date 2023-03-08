class_name Level
extends Node2D


@onready var root_obstacles = $RootObsCells
@onready var root_units = $RootUnits
@export var map_size: Vector2


var all_sorted_objects = []
var prev_transparent_objs = []
var cur_pointer_cell_pos: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)
	GlobalBus.on_hovered_cell.connect(_on_hovered_cell)

	for child in root_obstacles.get_children():
		all_sorted_objects.append(child)

	for child in root_units.get_children():
		all_sorted_objects.append(child)

	await get_tree().process_frame
	_update_visual()


func _process(delta: float) -> void:
	if GlobalUnits.units_manager.walking.is_unit_moving():
		_update_visual()


func _on_unit_died(id, killer):
	_update_visual()


func _update_visual():
	_update_ordering()
	_update_transparency()


func _update_ordering():
	all_sorted_objects.sort_custom(_sort_ascending)
	GlobalMap.draw_debug.clear_points_ordering()

	var i = 1
	var prev_obj
	for obj in all_sorted_objects:
		var same_origin_pos = prev_obj and prev_obj.origin_pos.y == obj.origin_pos.y
		obj.visual_ordering = prev_obj.visual_ordering if same_origin_pos else i
		prev_obj = obj

		if not same_origin_pos:
			i += 1

		GlobalMap.draw_debug.draw_object_order_point(obj.origin_pos, obj.visual_ordering)


func _sort_ascending(a, b):
	if not a or not b:
		return false

	return a.origin_pos.y < b.origin_pos.y


func _update_transparency():
	for prev in prev_transparent_objs:
		prev.comp_visual.make_transparent(false)

	prev_transparent_objs.clear()

	var units = GlobalUnits.units.values()
	for unit in units:
		for obj in all_sorted_objects:
			if obj == null or obj is UnitObject:
				continue

			if _can_hide(unit.unit_object.origin_pos, obj.origin_pos):
				prev_transparent_objs.append(obj)
				obj.comp_visual.make_transparent(true)

	for obj in all_sorted_objects:
		if obj and obj is UnitObject:
				continue

		if _can_hide(cur_pointer_cell_pos, obj.origin_pos):
			prev_transparent_objs.append(obj)
			obj.comp_visual.make_transparent(true)


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
