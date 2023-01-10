class_name CellFog
extends Sprite2D


@export var visibility: FogOfWar.CellVisibility = FogOfWar.CellVisibility.NOTHING


func update_visibility(cell_visibility: FogOfWar.CellVisibility):
	visibility = cell_visibility

	match cell_visibility:
		FogOfWar.CellVisibility.VISIBLE:
			modulate.a = 0.0

		FogOfWar.CellVisibility.HALF:
			modulate.a = 0.5

		FogOfWar.CellVisibility.NOTHING:
			modulate.a = 1.0
