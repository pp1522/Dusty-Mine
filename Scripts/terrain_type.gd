@tool
class_name TerrainType
extends Resource


enum TileType {Height, Biome}

@export var type: TileType = TileType.Height:
	set(value):
		if type != value:
			type = value
			emit_changed()
			notify_property_list_changed()

@export var name: String
@export var place_ore: bool = false
@export var threshold: float:
	set(value):
		if threshold != value:
			threshold = value
			emit_changed()

var biome_threshold: Array[float] = []:
	set(value):
		if biome_threshold != value:
			biome_threshold = value
			emit_changed()

var atlas: Vector2i
var biome_atlas: Array[Vector2i] = []


func _get_property_list():
	var properties = []

	properties.append({
		"name": "biome_threshold",
		"type": TYPE_ARRAY,
		"hint_string": "%d/%d:0,1,0.01" % [TYPE_FLOAT, PROPERTY_HINT_RANGE],
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Biome else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "atlas",
		"type": TYPE_VECTOR2I,
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Height else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "biome_atlas",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_ARRAY_TYPE,
		"hint_string": "%d/%d:Vector2i" % [TYPE_VECTOR2I, PROPERTY_HINT_NONE],
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Biome else PROPERTY_USAGE_NO_EDITOR
	})

	return properties
