@tool
class_name TerrainType
extends Resource

@export var name: String
@export_range(0.0, 1.0, 0.01) var threshold: float:
	set(value):
		if threshold != value:
			threshold = value
			emit_changed()
@export var atlas: Vector2i
