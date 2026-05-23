@tool
extends Node2D


@export var chunk_width = 32
@export var chunk_height = 32

@export var SEED = 1:
	set(value):
		if SEED != value:
			SEED = value
			gen_helper()

@export var height_noise: Noise:
	set(value):
		if height_noise != value:
			height_noise = value
			gen_helper()

@export var biome_noise: Noise:
	set(value):
		if biome_noise != value:
			biome_noise = value
			gen_helper()

@export var terrain_types: Array[TerrainType] = []:
	set(value):
		if terrain_types != value:
			terrain_types = value

			for terrain in terrain_types:
				if terrain:
					if not terrain.changed.is_connected(gen_helper):
						terrain.changed.connect(gen_helper)

			gen_helper()

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

var TILE_WIDTH = 32
var TILE_HEIGHT = 32

@export_tool_button("Regenerate Map")
var regenerate_action = gen_helper

func _ready() -> void:
	init_generator()

func _process(_delta: float) -> void:
	var cx:int = floor(camera.position.x / TILE_WIDTH / chunk_width)
	var cy:int = floor(camera.position.y / TILE_HEIGHT / chunk_height)

	for x in range(-1, 2):
		for y in range(-1, 2):
			generate_chunk(x + cx, y + cy)

func gen_helper():
	init_generator()
	generate_chunk()

func init_generator():
	if tilemap == null: return
	tilemap.clear()

	height_noise.seed = SEED
	biome_noise.seed = SEED

func place_biome(tile_pos: Vector2i, biome_value:float, terrain:TerrainType):
	for i in range(terrain.biome_threshold.size()):
		if biome_value < terrain.biome_threshold[i]:
			tilemap.set_cell(tile_pos, 0, terrain.biome_atlas[i])
			break

func generate_chunk(cx:int = 0, cy:int = 0):
	if tilemap == null: return

	for x in range(chunk_width):
		for y in range(chunk_height):
			var px = x + cx * chunk_width
			var py = y + cy * chunk_height

			var noise_value = height_noise.get_noise_2d(px, py)
			noise_value = (noise_value + 1) / 2

			var tile_pos = Vector2i(px, py)

			for terrain in terrain_types:
				if noise_value < terrain.threshold:
					if terrain.type == TerrainType.TileType.Height:
						tilemap.set_cell(tile_pos, 0, terrain.atlas)
						break
					elif terrain.type == TerrainType.TileType.Biome:
						var biome_value = biome_noise.get_noise_2d(px, py)
						biome_value = (biome_value + 1) / 2
						place_biome(tile_pos, biome_value, terrain)
						break
