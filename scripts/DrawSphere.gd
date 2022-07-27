extends ImmediateGeometry


func create_sphere(radius):
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	
	set_color(Color.red)
	add_sphere(8, 8, radius)
	
	end()
