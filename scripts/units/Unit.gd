class_name Unit
extends Node


var id: int
var unit_data: UnitData
var unit_object: UnitObject


func _init(id, unit_data, unit_object):
	self.id = id
	self.unit_data = unit_data
	self.unit_object = unit_object
	
	unit_data.set_unit_id(id)
	unit_object.init_unit(id, unit_data)


func _to_string() -> String:
	return "Unit id {0}".format([id])
