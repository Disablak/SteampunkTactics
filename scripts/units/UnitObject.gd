extends Spatial
class_name UnitObject


export var is_player_unit = true

var unit_id = -1

onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")
onready var unit_ui = get_node("UnitUI")


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id
	_update_health(unit_id, unit_data.cur_health, unit_data.max_health)


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_change_health_name, self, "_update_health")


func _update_health(unit_id, cur_health, max_health):
	if self.unit_id != unit_id:
		return
	
	unit_ui.update_health(cur_health, max_health)
