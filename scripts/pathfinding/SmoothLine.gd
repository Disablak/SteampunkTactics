extends Spatial


export(float, 0.0, 1) var smooth: float = 0.15


onready var curve = Curve3D.new()


func get_smoothed_curve(points: PoolVector3Array) -> PoolVector3Array:
	if points.size() <= 2:
		return points
	
	curve.clear_points()
	
	for idx in points.size():
		var prev_idx = idx-1
		var next_idx = idx+1
		if idx == 0 or idx == points.size()-1:
			prev_idx = points.size()-2
			next_idx = 1
		var idx_vec = points[idx]
		var prev_vec = points[prev_idx] - idx_vec
		var next_vec = points[next_idx] - idx_vec
		var prev_len = prev_vec.length()
		var next_len = next_vec.length()
		var dir_vec = ((prev_len / next_len) * next_vec - prev_vec).normalized()
		
		var leng = prev_len * smooth
		curve.add_point(idx_vec, -dir_vec*(leng), dir_vec*(leng))
	
	return curve.get_baked_points()

