class_name Gui
extends Control


signal building_select(building)

@export var terrain_gen: TerrainGen

@onready var minimap: MiniMap = $MiniMap

func _ready() -> void:
	minimap.terrain_gen = terrain_gen
	minimap.init_minimap()

func _on_building_select(building: Variant) -> void:
	building_select.emit(building)
