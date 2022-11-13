class_name CellObject
extends Resource


enum AtlasObjectType {NONE, GROUND, WALL}

@export var atlas_coords : Vector2i
@export var obj_type : AtlasObjectType = AtlasObjectType.NONE
