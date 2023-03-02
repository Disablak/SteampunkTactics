extends Node2D


@onready var root_obstacles = $RootObsCells
@onready var root_units = $RootUnits


var all_sorted_objects = []
var prev_transparent_objs = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in root_obstacles.get_children():
		all_sorted_objects.append(child)

	for child in root_units.get_children():
		all_sorted_objects.append(child)

	update_ordering()
	update_transparency()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update()


func update():
	update_ordering()
	update_transparency()


func update_ordering():
	all_sorted_objects.sort_custom(func(a, b): return a.origin_pos < b.origin_pos)

	var i = 1
	for obj in all_sorted_objects:
		obj.visual_ordering = i
		i += 1


func update_transparency():
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
