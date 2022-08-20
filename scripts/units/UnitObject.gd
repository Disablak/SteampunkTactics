extends Spatial
class_name UnitObject


export var is_player_unit = true
export var player_color = Color.white
export var enemy_color = Color.white

var unit_id = -1

onready var unit_visual = get_node("UnitVisual")
onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")
onready var skeleton = get_node("UnitVisual/y bot 2/Armature/Skeleton")

const DIE_POWER = 30


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id

	unit_visual.set_unit_color(player_color if is_player_unit else enemy_color)


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name, self, "_on_unit_died")


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return
	
	enable_ragdoll(unit_id_killer)
	


func enable_ragdoll(unit_id_killer):
	global_transform.origin
	skeleton.physical_bones_start_simulation()
	var head: PhysicalBone = skeleton.get_node("Physical Bone Head")
	var enemy_obj: Spatial = GlobalUnits.units[unit_id_killer].unit_object
	var dir = (global_transform.origin - enemy_obj.global_transform.origin).normalized()
	head.apply_central_impulse(dir * DIE_POWER)
