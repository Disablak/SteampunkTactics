extends Spatial


export(NodePath) var path_to_mesh
onready var unit_mesh = get_node(path_to_mesh)

export(NodePath) var path_vfx_muzzle_flesh
onready var vfx_muzzle_flesh = get_node(path_vfx_muzzle_flesh)
onready var anim_player_muzzle_flesh : AnimationPlayer = vfx_muzzle_flesh.get_node("AnimationPlayer")


func _ready() -> void:
	pass


func set_unit_color(color: Color):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	unit_mesh.material_override = material


func play_fire_vfx():
	anim_player_muzzle_flesh.play("Fire")
