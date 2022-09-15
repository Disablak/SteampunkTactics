@tool
extends MultiMeshInstance3D

@export var extents := Vector2.ONE
@export var grass_size = 0.2

@onready var GRASS_SIZE = Vector3(grass_size, grass_size, grass_size)

func _enter_tree() -> void:
	connect("visibility_changed",Callable(self,"_on_MultiMeshGrass_visibility_changed"))


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var theta := 0
	var increase := 1
	var center: Vector3 = get_parent().global_transform.origin

	for instance_index in multimesh.instance_count:
		var transform := Transform3D().rotated(Vector3.UP, rng.randf_range(-PI / 2, PI / 2))
		transform = transform.scaled(GRASS_SIZE)
		
		var x: float
		var z: float
		
		x = rng.randf_range(-extents.x, extents.x)
		z = rng.randf_range(-extents.y, extents.y)
			
		transform.origin = Vector3(x, 0, z)

		multimesh.set_instance_transform(instance_index, transform)


func _on_WindGrass_visibility_changed() -> void:
	if visible:
		_ready()

