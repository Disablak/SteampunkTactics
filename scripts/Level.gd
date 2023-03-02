extends Node2D


@onready var root_obstacles = $RootObsCells
@onready var root_units = $RootUnits

var all_sorted_objects = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in root_obstacles.get_children():
		all_sorted_objects.append(child)

	for child in root_units.get_children():
		all_sorted_objects.append(child)

	update_ordering()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	update_ordering()


func update_ordering():
	all_sorted_objects.sort_custom(func(a, b): return a.origin_pos < b.origin_pos)

	var i = 1
	for obj in all_sorted_objects:
		obj.visual_ordering = i
		i += 1
