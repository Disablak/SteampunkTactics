extends Spatial
class_name UnitObject


export var is_player_unit = true
export var player_color = Color.white
export var enemy_color = Color.white

var unit_id = -1

onready var unit_visual = get_node("UnitVisual")
onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")
onready var unit_ui = get_node("UnitUI")


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id
	
	_update_health(unit_id, unit_data.cur_health, unit_data.max_health)
	_update_walk_distance(unit_id, unit_data.cur_walk_distance, unit_data.max_walk_distance)
	
	unit_visual.set_unit_color(player_color if is_player_unit else enemy_color)


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_change_health_name, self, "_update_health")
	GlobalBus.connect(GlobalBus.on_unit_changed_walk_distance, self, "_update_walk_distance")


func _update_health(unit_id, cur_health, max_health):
	if self.unit_id != unit_id:
		return
	
	unit_ui.update_health(cur_health, max_health)


func _update_walk_distance(unit_id, cur_distance, max_distance):
	if self.unit_id != unit_id:
		return
	
	unit_ui.update_walk_distance(cur_distance, max_distance)


