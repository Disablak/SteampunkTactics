class_name CellRoof
extends Sprite2D


var origin_pos: Vector2:
	get: return position + Globals.CELL_OFFSET


func make_transparent(enable: bool):
	modulate.a = 0.5 if enable else 1.0
