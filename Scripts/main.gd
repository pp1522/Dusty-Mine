@tool
extends Node2D


@export var TILE_SIZE: Vector2i = Vector2i(32, 32)
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

@export var ore_noise: Noise:
	set(value):
		if ore_noise != value:
			ore_noise = value
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

@export var ores_types: Array[TerrainType] = []:
	set(value):
		if ores_types != value:
			ores_types = value

			for ores in ores_types:
				if ores:
					if not ores.changed.is_connected(gen_helper):
						ores.changed.connect(gen_helper)

			gen_helper()

@onready var tilemap: TileMapLayer = $Tiles/Ground
@onready var ores_tilemap: TileMapLayer = $Tiles/Ores
@onready var camera: Camera2D = $Camera2D

var debug = false
var ore_noises: Dictionary = {}

@export_tool_button("Regenerate Map")
var regenerate_action = gen_helper

func _ready() -> void:
	init_generator()

func _process(_delta: float) -> void:
	var cx:int = floor(camera.position.x / TILE_SIZE.x / chunk_width)
	var cy:int = floor(camera.position.y / TILE_SIZE.y / chunk_height)

	if debug: init_generator()

	for x in range(-1, 2):
		for y in range(-1, 2):
			generate_chunk(x + cx, y + cy)

func gen_helper():
	init_generator()
	generate_chunk()

func init_generator():
	if tilemap == null: return
	if ores_tilemap == null: return
	tilemap.clear()
	ores_tilemap.clear()

	var rng = RandomNumberGenerator.new()
	rng.seed = SEED

	height_noise.seed = rng.randi()
	biome_noise.seed = rng.randi()

	ore_noises.clear()

	for ore in ores_types:
		if ore == null: continue

		var noise := ore_noise.duplicate()
		noise.seed = hash(str(SEED) + ore.name)

		ore_noises[ore] = noise

func generate_chunk(cx:int = 0, cy:int = 0):
	if tilemap == null: return
	if ores_tilemap == null: return

	for x in range(chunk_width):
		for y in range(chunk_height):
			var px = x + cx * chunk_width
			var py = y + cy * chunk_height

			var noise_value = height_noise.get_noise_2d(px, py)
			noise_value = (noise_value + 1) / 2

			var tile_pos = Vector2i(px, py)

			for terrain in terrain_types:
				if terrain and noise_value < terrain.threshold:
					if terrain.type == TerrainType.TileType.Height:
						tilemap.set_cell(tile_pos, 0, terrain.atlas)
					elif terrain.type == TerrainType.TileType.Biome:
						var biome_value = biome_noise.get_noise_2d(px, py)
						biome_value = (biome_value + 1) / 2
						place_biome(tile_pos, biome_value, terrain)

					if terrain.place_ore:
						place_ores(tile_pos, px, py)

					break

func place_biome(tile_pos: Vector2i, biome_value: float, terrain: TerrainType):
	for i in range(terrain.biome_threshold.size()):
		if (biome_value < terrain.biome_threshold[i]) and (i < terrain.biome_atlas.size()):
			tilemap.set_cell(tile_pos, 0, terrain.biome_atlas[i])
			break

func place_ores(tile_pos: Vector2i, px: int, py: int):
	for ore in ores_types:
		if ore == null: continue

		var noise: Noise = ore_noises[ore]
		if noise == null: continue

		var ore_value = noise.get_noise_2d(px, py)
		ore_value = (ore_value + 1.0) / 2.0

		if ore_value < ore.threshold:
			if ore.type == TerrainType.TileType.Height:
				ores_tilemap.set_cell(tile_pos, 0, ore.atlas)
				break
