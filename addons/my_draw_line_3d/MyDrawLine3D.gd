tool
class_name DrawLine3D
extends MeshInstance

export var thickness = 0.1
export var square_size = 0.2
export var color := Color.white

var points: PoolVector3Array
var arrays = []
var meterial: SpatialMaterial


func _enter_tree() -> void:
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_TEX_UV] = PoolVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	arrays[ArrayMesh.ARRAY_INDEX] = PoolIntArray([0, 1, 2,  0, 2, 3])
	
	meterial = SpatialMaterial.new()
	meterial.albedo_color = color


func draw_all_lines(points: PoolVector3Array):
	draw_all_lines_colored(points, self.color)


func draw_all_lines_colored(points: PoolVector3Array, new_color: Color):
	clear()
	
	self.points = points
	meterial.albedo_color = new_color
	
	for i in points.size():
		if i == points.size() - 1:
			return
		
		arrays[ArrayMesh.ARRAY_VERTEX] = _create_line( points[i], points[i + 1] )
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(i, meterial)


func draw_squares(points: PoolVector3Array):
	clear()
	
	self.points = points
	
	for i in points.size():
		arrays[ArrayMesh.ARRAY_VERTEX] = _create_square(points[i], square_size)
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(i, meterial)


func clear():
	self.points = []
	mesh = ArrayMesh.new()


func _create_line(point_a: Vector3, point_b: Vector3) -> PoolVector3Array:
	var dir = point_b - point_a
	var left = dir.cross(Vector3.UP).normalized()
	left *= thickness / 2
	
	var result = PoolVector3Array([
		Vector3(point_a.x, point_a.y, point_a.z) + left,
		Vector3(point_a.x, point_a.y, point_a.z) - left,
		Vector3(point_b.x, point_b.y, point_b.z) - left,
		Vector3(point_b.x, point_b.y, point_b.z) + left,
	])
	return result
	
func _create_square(pos: Vector3, size: float) -> PoolVector3Array:
	var half_size = size / 2
	
	var result = PoolVector3Array([
		Vector3(pos.x - half_size, pos.y, pos.z - half_size),
		Vector3(pos.x + half_size, pos.y, pos.z - half_size),
		Vector3(pos.x + half_size, pos.y, pos.z + half_size),
		Vector3(pos.x - half_size, pos.y, pos.z + half_size),
	])
	return result
