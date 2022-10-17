extends Node2D
class_name UnitObject


var unit_id = -1

#@onready var unit_visual = get_node("UnitVisual")
#@onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")
#@onready var unit_collision = get_node("UnitArea/CollisionShape3D")


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name,Callable(self,"_on_unit_died"))


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return
	
	queue_free()
