extends Node3D
class_name UnitObject


@export var is_player_unit = true
@export var player_color = Color.WHITE
@export var enemy_color = Color.WHITE

@export var path_to_hit_points: NodePath
@onready var hit_point_parent = get_node(path_to_hit_points)

@export var path_to_shoot_point: NodePath
@onready var shoot_point_node = get_node(path_to_shoot_point)

@export var hit_bullet_point_path: NodePath
@onready var hit_bullet_point = get_node(hit_bullet_point_path)


var unit_id = -1

@onready var unit_visual = get_node("UnitVisual")
@onready var unit_animator : UnitAnimator = get_node("UnitVisual/AnimationTree")
@onready var skeleton = get_node("UnitVisual/y bot 2/Armature/Skeleton3D")
@onready var unit_collision = get_node("UnitArea/CollisionShape3D")
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3d

const DIE_POWER = 30


func init_unit(unit_id, unit_data) -> void:
	self.unit_id = unit_id

	unit_visual.set_unit_color(player_color if is_player_unit else enemy_color)


func _ready() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name,Callable(self,"_on_unit_died"))


func _on_unit_died(unit_id, unit_id_killer):
	if self.unit_id != unit_id:
		return
	
	enable_ragdoll(unit_id_killer)
	unit_collision.disabled = true
	


func enable_ragdoll(unit_id_killer):
	global_transform.origin
	skeleton.physical_bones_start_simulation()
	var head: PhysicalBone3D = skeleton.get_node("Physical Bone Head")
	var enemy_obj: Node3D = GlobalUnits.units[unit_id_killer].unit_object
	var dir = (global_transform.origin - enemy_obj.global_transform.origin).normalized()
	head.apply_central_impulse(dir * DIE_POWER)


func get_shoot_point():
	return shoot_point_node.global_transform.origin


func get_hit_points():
	var hit_points: PackedVector3Array
	
	for child in hit_point_parent.get_children():
		hit_points.push_back(child.global_transform.origin)
	
	return hit_points


func get_move_path(target_pos : Vector3) -> PackedVector3Array:
	navigation_agent.set_target_location(target_pos)
	if navigation_agent.is_target_reachable():# if not use this method path return zero! 
		return navigation_agent.get_nav_path()
	else:
		print("path not reachable")
		return PackedVector3Array()
