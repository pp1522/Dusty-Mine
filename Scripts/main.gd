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

@onready var liquid_tilemap: TileMapLayer = $Tiles/Liquid
@onready var tilemap: TileMapLayer = $Tiles/Ground
@onready var mineable_tilemap: TileMapLayer = $Tiles/Ground_Mineable
@onready var ores_tilemap: TileMapLayer = $Tiles/Ores
@onready var camera: Camera2D = $Camera2D

var debug = true
var ore_noises: Dictionary = {}
var loaded_chunks: Dictionary = {}

@export_tool_button("Regenerate Map")
var regenerate_action = gen_helper

func _ready() -> void:
	init_generator()

func _process(_delta: float) -> void:
	var cx:int = floor(camera.position.x / TILE_SIZE.x / chunk_width)
	var cy:int = floor(camera.position.y / TILE_SIZE.y / chunk_height)

	if debug: init_generator()

	var chunks: Array[Vector2i] = []

	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk = Vector2i(x+cx, y+cy)

			chunks.append(chunk)

			if loaded_chunks.has(chunk):
				continue
			else:
				generate_chunk(chunk)
				loaded_chunks[chunk] = true

	for c in loaded_chunks.keys():
		if !chunks.has(c):
			remove_chunk(c)
			loaded_chunks.erase(c)

func gen_helper():
	init_generator()
	generate_chunk()

func init_generator():
	if liquid_tilemap == null: return
	if tilemap == null: return
	if mineable_tilemap == null: return
	if ores_tilemap == null: return

	liquid_tilemap.clear()
	tilemap.clear()
	mineable_tilemap.clear()
	ores_tilemap.clear()

	loaded_chunks = {}

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

func generate_chunk(chunk: Vector2i = Vector2i(0, 0)):
	if liquid_tilemap == null: return
	if tilemap == null: return
	if mineable_tilemap == null: return
	if ores_tilemap == null: return

	for x in range(chunk_width):
		for y in range(chunk_height):
			var px = x + chunk.x * chunk_width
			var py = y + chunk.y * chunk_height

			var noise_value = height_noise.get_noise_2d(px, py)
			noise_value = (noise_value + 1) / 2

			var tile_pos = Vector2i(px, py)

			for terrain in terrain_types:
				if terrain and noise_value < terrain.threshold:
					if terrain.type == TerrainType.TileType.Height:
						place_tile(tile_pos, terrain.atlas, terrain.is_liquid, terrain.is_mineable)
					elif terrain.type == TerrainType.TileType.Biome:
						var biome_value = biome_noise.get_noise_2d(px, py)
						biome_value = (biome_value + 1) / 2
						place_biome(tile_pos, biome_value, terrain)

					if terrain.place_ore:
						place_ores(tile_pos, px, py)

					break

func place_tile(tile_pos: Vector2i, atlas: Vector2i, is_liquid: bool, is_mineable: bool):
	if is_liquid:
		liquid_tilemap.set_cell(tile_pos, 0, atlas)
	elif is_mineable:
		mineable_tilemap.set_cell(tile_pos, 0, atlas)
	else:
		tilemap.set_cell(tile_pos, 0, atlas)

func place_biome(tile_pos: Vector2i, biome_value: float, terrain: TerrainType):
	for i in range(terrain.biome_threshold.size()):
		if ((biome_value < terrain.biome_threshold[i]) and
			(i < terrain.biome_atlas.size()) and
			(i < terrain.tile_is_liquid.size()) and
			(i < terrain.tile_is_mineable.size())):
			place_tile(tile_pos, terrain.biome_atlas[i], terrain.tile_is_liquid[i], terrain.tile_is_mineable[i])
			break

func place_ores(tile_pos: Vector2i, px: int, py: int):
	for ore in ores_types:
		if ore == null: continue

		var noise: Noise = ore_noises[ore]
		if noise == null: continue

		var ore_value = noise.get_noise_2d(px, py)
		ore_value = (ore_value + 1.0) / 2.0

		if ore_value < ore.threshold:
			if ore.type == TerrainType.TileType.Ore:
				ores_tilemap.set_cell(tile_pos, 0, ore.atlas)
				break

func remove_tile(tile_pos: Vector2i):
	liquid_tilemap.erase_cell(tile_pos)
	mineable_tilemap.erase_cell(tile_pos)
	tilemap.erase_cell(tile_pos)
	ores_tilemap.erase_cell(tile_pos)

func remove_chunk(chunk: Vector2i):
	if liquid_tilemap == null: return
	if tilemap == null: return
	if mineable_tilemap == null: return
	if ores_tilemap == null: return
	if !loaded_chunks.has(chunk): return

	for x in range(chunk_width):
		for y in range(chunk_height):
			var px = x + chunk.x * chunk_width
			var py = y + chunk.y * chunk_height

			var tile_pos = Vector2i(px, py)

			remove_tile(tile_pos)
