extends Spatial


func make_points_smooth(path: Path) -> PoolVector3Array:
	var result = PoolVector3Array()
	
	var points = path.curve.tessellate()
	var size = points.size()
	
	if size % 2 == 0 && size > 1: 
		var a = points[size-1]
		var b = points[size-2]
		var c = a.linear_interpolate(b, 0.5)
		points.insert(size-1, c)
	
	result.push_back(points[0])
	var last_m = Vector3()
	for i in range(0, size, 2):
		var a = points[i]
		var b = points[i+1] if i < size - 1  else points[i]
		var c = points[i+2] if i < size - 2  else points[i]
		var m1 = _quadratic_bezier(a, b, c, 0.2)
		var m2 = _quadratic_bezier(a, b, c, 0.4)
		var m3 = _quadratic_bezier(a, b, c, 0.6)
		var m4 = _quadratic_bezier(a, b, c, 0.8)
		
		if (i != 0):
			var e = last_m
			var f = points[i]
			var g = m1
			var n1 = _quadratic_bezier(e, f, g, 0.33)
			var n2 = _quadratic_bezier(e, f, g, 0.66)
			result.push_back(n1)
			result.push_back(n2)
		
		result.push_back(m1)
		result.push_back(m2)
		result.push_back(m3)
		result.push_back(m4)
		last_m = m4
	
	result.push_back(points[size-1])
	
	return result


func _quadratic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)

	var r = q0.linear_interpolate(q1, t)
	return r
