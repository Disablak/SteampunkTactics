extends Node3D


@export var original_material: Material
@export var unit_mesh: MeshInstance3D = null 
@export var muzzle_flesh: Node3D

@onready var anim_player_muzzle_flesh : AnimationPlayer = muzzle_flesh.get_node("AnimationPlayer")

var unit_material: Material


func _ready() -> void:
	pass


func set_unit_color(color: Color):
	unit_material = original_material.duplicate(true)
	unit_material.albedo_color = color
	unit_mesh.material_override = unit_material
	_enable_outline(false)


func make_outline_effect():
	var time = .5

	_enable_outline(true)
	await get_tree().create_timer(time).timeout
	_enable_outline(false)


func _enable_outline(enable):
	unit_material.next_pass.set_shader_parameter("outline_width", 2.0 if enable else 0.0)


func play_fire_vfx():
	anim_player_muzzle_flesh.play("Fire")
