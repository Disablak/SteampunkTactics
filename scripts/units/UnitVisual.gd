extends Spatial


onready var unit_mesh = get_node("ybot/Armature/Skeleton/Alpha_Surface")


func _ready() -> void:
	pass


func set_unit_color(color: Color):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	unit_mesh.material_override = material
