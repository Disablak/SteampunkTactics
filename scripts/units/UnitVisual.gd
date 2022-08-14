extends Spatial


export(NodePath) var path_to_mesh
onready var unit_mesh = get_node(path_to_mesh)


func _ready() -> void:
	pass


func set_unit_color(color: Color):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	unit_mesh.material_override = material
