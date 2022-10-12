extends Node2D


@export var cell_size : Vector2i

@onready var player := $Player as Sprite2D
@onready var pathfinding := $Pathfinding
@onready var offset_cell : Vector2 = cell_size / 2

var tween_move : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var path = pathfinding.get_path_to_point(convert_to_tile_pos(player.position), convert_to_tile_pos(event.position))
		print(path)
		_move_via_points(path)


func convert_to_tile_pos(rect_pos : Vector2i) -> Vector2i:
	return rect_pos / cell_size.x

func convert_to_rect_pos(tile_pos : Vector2) -> Vector2:
	return tile_pos * cell_size.x + offset_cell
	

func _move_via_points(points: PackedVector2Array):
	var cur_target_id = 0
	
	for point in points:
		if cur_target_id == points.size() - 1:
			return
		
		var start_point = convert_to_rect_pos(points[cur_target_id])
		var finish_point = convert_to_rect_pos(points[cur_target_id + 1])
		var time_move = start_point.distance_to(finish_point) / 500
		
		tween_move = get_tree().create_tween()
		tween_move.tween_property(
			player,
			"position",
			finish_point,
			time_move
		).from(start_point)
		
		cur_target_id += 1
		await tween_move.finished 
