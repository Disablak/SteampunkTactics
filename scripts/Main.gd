extends Spatial


onready var pathfinding_system = get_node("World/Level/PathfindingSystem")
onready var player = get_node("World/UnitObject")
onready var enemy = get_node("World/UnitObject2")
onready var draw_line3d = get_node("World/Level/DrawLine3D")
onready var path = get_node("World/Level/Path")
onready var smooth_line = $World/Level/SmoothLine

var tween_move := Tween.new()
var cur_target_point := Vector3.ZERO

var units = {}

const move_speed = 2
const rot_speed = 10

class Unit:
	var id: int
	var unit_data: UnitData
	var unit_object: UnitObject
	
	func _init(id, unit_data, unit_object):
		self.id = id
		self.unit_data = unit_data
		self.unit_object = unit_object
		
		unit_data.set_unit_id(id)
		unit_object.init_unit(id, unit_data)


func _init() -> void:
	GlobalBus.connect(GlobalBus.on_unit_died_name, self, "_on_unit_died")


func _enter_tree() -> void:
	add_child(tween_move)



func _ready() -> void:
	OS.set_window_always_on_top(true)
	
	_init_units()


func _init_units():
	var all_units = [
		Unit.new(0, UnitData.new(20), player),
		Unit.new(1, UnitData.new(20), enemy) 
	]
	
	for i in all_units.size():
		units[all_units[i].id] = all_units[i]
		
	print(units)


func _process(delta: float) -> void:
	if cur_target_point == Vector3.ZERO:
		return
	
	var new_transform = player.transform.looking_at(cur_target_point, Vector3.UP)
	player.transform = player.transform.interpolate_with(new_transform, rot_speed * delta)
	player.rotation.x = 0


func move_via_points(points: PoolVector3Array):
	draw_line3d.draw_all_lines(points)
	
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			player.unit_animator.play_anim(Globals.AnimationType.IDLE)
			draw_line3d.clear()
			cur_target_point = Vector3.ZERO
			print("finish!")
			return
		
		cur_target_point = points[cur_target_id + 1]
		
		player.unit_animator.play_anim(Globals.AnimationType.WALKING)
		var time_move = points[cur_target_id].distance_to(points[cur_target_id + 1]) / move_speed
		
		tween_move.interpolate_property(
			player,
			"translation",
			points[cur_target_id], 
			points[cur_target_id + 1],
			time_move
		)
		
		tween_move.start()
		
		cur_target_id += 1
		yield(tween_move, "tween_completed") 


func _move_unit(pos):
	var path = pathfinding_system.find_path(player.global_transform.origin, pos)
	move_via_points(path)


func _on_CameraPivot_on_click_world(raycast_result) -> void:
	if tween_move.is_active():
		return
	
	if raycast_result.collider.name == "Area":
		return
	
	if raycast_result.collider.is_in_group("pathable"):
		if raycast_result.position != Vector3.ZERO:
			_move_unit(raycast_result.position)
			return
	
	var unit_object = raycast_result.collider.get_parent()
	if not unit_object.is_player_unit:
		units[unit_object.unit_id].unit_data.set_damage(10)


func _on_unit_died(unit_id):
	var unit: Unit = units[unit_id]
	unit.unit_object.queue_free()
	
	units.erase(unit_id)

