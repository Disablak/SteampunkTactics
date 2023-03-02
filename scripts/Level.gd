extends Node2D


@onready var root_obstacles = $RootObsCells
@onready var root_units = $RootUnits


var all_sorted_objects = []
var prev_transparent_objs = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalBus.on_unit_died.connect(_on_unit_died)

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

	var i = 1
	for obj in all_sorted_objects:
		obj.visual_ordering = i
		i += 1


func _sort_ascending(a, b):
	if not a or not b:
		return false

	return a.origin_pos < b.origin_pos


func _update_transparency():
	for prev in prev_transparent_objs:
		prev.make_transparent(false)

	prev_transparent_objs.clear()

	var units = GlobalUnits.units.values()
	for unit in units:
		for obj in all_sorted_objects:
			if obj is UnitObject:
				continue

			if obj.origin_pos.y < unit.unit_object.origin_pos.y:
				continue

			if abs(obj.origin_pos.y - unit.unit_object.origin_pos.y) > 16:
				continue

			if abs(obj.origin_pos.x - unit.unit_object.origin_pos.x) > 6:
				continue

			prev_transparent_objs.append(obj)
			obj.make_transparent(true)
