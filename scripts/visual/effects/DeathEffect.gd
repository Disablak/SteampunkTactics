extends Node2D


@export var traectory_curve: Curve
@export var visual_obj: PackedScene
@export var parts_count = 16

var parts: Array[Sprite2D]

var height = 15
var width = 20
var duration = 0.5
var max_height_finish = 5
var jump_length_mod = [0.5, 0.75, 0.85]
var jump_time_mod = [0.5, 0.35, 0.2]
var jump_height_mod = [1.0, 0.5, 0.2]


func play_effect(unit_texture_region: Rect2):
	var region_parts: Array[Rect2]
	var part_step := 4
	for x in range(unit_texture_region.position.x, unit_texture_region.end.x, part_step):
		for y in range(unit_texture_region.position.y, unit_texture_region.end.y, part_step):
			region_parts.append(Rect2(x, y, part_step, part_step))

	for part_idx in parts_count:
		var part: Sprite2D = visual_obj.instantiate() as Sprite2D
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = ImageTexture.create_from_image(Globals.main_atlas_image)
		atlas_texture.region = region_parts.pick_random()
		part.texture = atlas_texture
		add_child(part)

		var begin_pos := part.position
		var random_target_y = randi_range(-part.texture.get_size().y, -part.texture.get_size().y + max_height_finish)
		var target_pos := Vector2(randi_range(-width, width), random_target_y)
		var target_vector := target_pos - begin_pos
		var target_dir := target_vector.normalized()
		var target_length := target_vector.length()

		var tween = create_tween()

		var prev_finish_pos: Vector2
		for i in jump_length_mod.size():
			var start_pos = begin_pos if i == 0 else prev_finish_pos
			var finish_pos: Vector2 = begin_pos + (target_dir * (target_length * jump_length_mod[i]))
			prev_finish_pos = finish_pos

			var dur = duration * jump_time_mod[i]
			var new_height = (height * jump_height_mod[i])
			tween.chain().tween_method(func(value): _tween_part(part, value, start_pos, finish_pos, new_height), 0.0, 1.0, dur)
			tween.set_trans(Tween.TRANS_CUBIC)

		#tween.parallel().tween_property(part, "rotation_degrees", randi_range(0, 360), duration)


func _tween_part(part: Sprite2D, value: float, from: Vector2, to: Vector2, height: int):
	var lerp_pos = lerp(from, to, value)
	part.position = Vector2(lerp_pos.x, lerp_pos.y - (traectory_curve.sample(value) * height))

