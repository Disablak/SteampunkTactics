extends Spatial

export(NodePath) var path_level = null
onready var node_level: Spatial = get_node(path_level)

onready var pathfinder_system = get_node("%PathfindingSystem")
onready var units_controller = get_node("%UnitsController")


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_init_units()
	pathfinder_system.level = node_level
	units_controller.set_unit_control(0, true)


func _init_units():
	var all_units = [
			Unit.new(0, UnitData.new(50, 20), get_node("%UnitObjectPlayer")),
			Unit.new(1, UnitData.new(30, 20), get_node("%UnitObjectEnemy"))
		]
	
	for i in all_units.size():
		GlobalUnits.units[all_units[i].id] = all_units[i]


func _on_BtnMoveUnit_toggled(button_pressed: bool) -> void:
	units_controller.move_unit_mode(button_pressed)


func _on_BtnNextTurn_button_down() -> void:
	units_controller.next_unit()
