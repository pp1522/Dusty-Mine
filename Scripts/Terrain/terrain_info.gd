class_name TerrainInfo
extends Resource


@export var name: String
@export_range(0.0, 1.0, 0.01) var threshold: float
@export var atlas: Vector2i
@export var tile_is_liquid: bool = false
@export var tile_is_mineable: bool = false

@export var minimap_color: Color = Color.MAGENTA
