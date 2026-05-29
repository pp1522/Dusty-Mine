@tool
class_name TerrainType
extends Resource


enum TileType {Height, Biome, Ore}

@export var type: TileType = TileType.Height:
	set(value):
		if type != value:
			type = value
			emit_changed()
			notify_property_list_changed()

@export var name: String
@export var threshold: float:
	set(value):
		if threshold != value:
			threshold = value
			emit_changed()

var place_ore: bool = false

var biome_info: Array[TerrainInfo] = []:
	set(value):
		if biome_info != value:
			biome_info = value
			emit_changed()

var atlas: Vector2i
var is_liquid: bool = false
var is_mineable: bool = false

func _get_property_list():
	var properties = []

	properties.append({
		"name": "place_ore",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Height else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "biome_info",
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_ARRAY_TYPE,
		"hint_string": "TerrainInfo",
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Biome else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "atlas",
		"type": TYPE_VECTOR2I,
		"usage": PROPERTY_USAGE_DEFAULT if (type == TileType.Height) or (type == TileType.Ore) else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "is_liquid",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Height else PROPERTY_USAGE_NO_EDITOR
	})

	properties.append({
		"name": "is_mineable",
		"type": TYPE_BOOL,
		"usage": PROPERTY_USAGE_DEFAULT if type == TileType.Height else PROPERTY_USAGE_NO_EDITOR
	})

	return properties
