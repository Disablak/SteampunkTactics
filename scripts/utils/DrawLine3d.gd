extends ImmediateGeometry


export var points: PoolVector3Array = PoolVector3Array()


func add_points(points: PoolVector3Array):
	self.points = points

func clear_points():
	points = PoolVector3Array()

func _process(delta: float) -> void:
	clear()
	
	begin(Mesh.PRIMITIVE_LINE_STRIP);
	
	set_color(Color.green)
	
	for point in points:
		add_vertex(point)
	
	
	end()
