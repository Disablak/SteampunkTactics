extends Spatial
class_name UnitObject


export var is_player_unit = true
export var player_color = Color.white
export var enemy_color = Color.white

var unit_id = -1

onready var unit_visual = get_node("UnitVisual")
onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id

	unit_visual.set_unit_color(player_color if is_player_unit else enemy_color)
