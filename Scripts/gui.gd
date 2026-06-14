class_name Gui
extends Control


signal building_select(building: String)

@export var terrain_gen: TerrainGen

@onready var minimap: MiniMap = $MiniMap
@onready var items: Items = $Items

var core_data: Array[ResourceType] = []

func _ready() -> void:
	minimap.terrain_gen = terrain_gen
	minimap.init_minimap()

func update_items():
	for i in core_data:
		if !items.resources.has(i):
			items.resources[i] = 0
		items.resources[i] += 1
	items.update_item()

func _on_building_select(building: String) -> void:
	building_select.emit(building)
