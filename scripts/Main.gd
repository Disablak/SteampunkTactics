extends Spatial

onready var player = get_node("%UnitObjectPlayer")
onready var enemy = get_node("%UnitObjectEnemy")


class Unit:
	var id: int
	var unit_data: UnitData
	var unit_object: UnitObject
	
	func _init(id, unit_data, unit_object):
		self.id = id
		self.unit_data = unit_data
		self.unit_object = unit_object
		
		unit_data.set_unit_id(id)
		unit_object.init_unit(id, unit_data)


func _ready() -> void:
	_init_units()


func _init_units():
	var all_units = [
		Unit.new(0, UnitData.new(50, 20), player),
		Unit.new(1, UnitData.new(30, 20), enemy)
	]
	
	for i in all_units.size():
		GlobalUnits.units[all_units[i].id] = all_units[i]
	
	$UnitsController.set_unit_control(0)
