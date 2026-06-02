extends Node2D


const BUILDING = {
	"drill": preload("res://Object/building/drill.tscn"),
	"belt": preload("res://Object/building/belt.tscn")
}

@export var TILE_SIZE: Vector2i = Vector2i(32, 32)
@export var player: Node2D
@export var reach: int = 12

@export var liquid_tile: TileMapLayer
@export var ground_tile: TileMapLayer
@export var mineable_ground_tile: TileMapLayer
@export var ore_tile: TileMapLayer

@export var spawner: MultiplayerSpawner

@onready var build_preview: Node2D = $BuildPreview
@onready var build_global: Node2D = $Build

@export var ores_data: Array[OreType] = []

var select_building: String = ""
var current_building: Sprite2D
var old_pos: Vector2
var building_object: PackedScene
var current_rotation: float = 0.0

func _ready() -> void:
	if NetworkHandler.single:
		spawner.queue_free()
	else:
		spawner.add_spawnable_scene("res://Object/building/drill.tscn")
		spawner.add_spawnable_scene("res://Object/building/belt.tscn")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("place") and current_building:
		queue_building()

	elif Input.is_action_just_pressed("remove") and current_building:
		current_building.queue_free()
		current_building = null
		select_building = ""

	elif Input.is_action_just_pressed("remove"):
		queue_remove()

	elif Input.is_action_just_pressed("rotate") and current_building:
		current_rotation = wrapf(current_rotation+90.0, 0.0, 360.0)
		current_building.building_rotate(current_rotation)

func _process(_delta: float) -> void:
	if current_building:
		snap(current_building, get_global_mouse_position())
	elif select_building:
		set_current_building(select_building)

	for c in build_global.get_children():
		if player.get_child_count() == 0: return
		for p in player.get_children():
			var distance = c.global_position.distance_to(p.player.global_position)
			if distance <= reach*TILE_SIZE.x:
				if c.remove:
					c.queue_free()
				elif c.queue:
					place_building(c)

func update_highlight(newBuilding):
	if is_valid(newBuilding):
		newBuilding.modulate.r = 0.0
		newBuilding.modulate.g = 1.0
	else:
		newBuilding.modulate.r = 1.0
		newBuilding.modulate.g = 0.0

func snap(newBuilding: Sprite2D, pos: Vector2):
	newBuilding.global_position = pos - TILE_SIZE/2.0

	var offset = Vector2(0, 0)
	if int(newBuilding.rect.size.x) % (TILE_SIZE.x*2) != 0:
		offset = TILE_SIZE/2.0

	newBuilding.global_position = newBuilding.global_position.snapped(TILE_SIZE) + offset

	if newBuilding.global_position != old_pos:
		old_pos = newBuilding.global_position
		update_highlight(newBuilding)

func get_cover(newBuilding):
	var rect = newBuilding.get_global_rect()

	var local_start = ground_tile.to_local(rect.position)
	var local_end = ground_tile.to_local(rect.position + rect.size)

	var tile_start = ground_tile.local_to_map(local_start)
	var tile_end = ground_tile.local_to_map(local_end - Vector2(1, 1))

	var tiles: Array[Vector2i] = []

	for x in range(tile_start.x, tile_end.x+1):
		for y in range(tile_start.y, tile_end.y+1):
			tiles.append(Vector2i(x, y))

	return tiles

func is_valid(newBuilding: Sprite2D):
	var intersects = []

	for child in build_global.get_children():
		if child == newBuilding: continue

		if child.get_global_rect().intersects(newBuilding.get_global_rect()):
			intersects.append(child)

	if intersects.size() != 0: return false

	var cover = get_cover(newBuilding)

	# tile stuff
	var ore_cover = 0
	for t in cover:
		var tile_data = ground_tile.get_cell_tile_data(t)
		var liquid_tile_data = liquid_tile.get_cell_tile_data(t)
		var ore_tile_data = ore_tile.get_cell_tile_data(t)
		var ground_tile_data = mineable_ground_tile.get_cell_tile_data(t)

		if not newBuilding.can_place_on_ground and tile_data:
			return false

		if not newBuilding.can_place_on_liquid and liquid_tile_data:
			return false

		if newBuilding.require_place_on_ore and ore_tile_data:
			ore_cover += 1

		if newBuilding.require_place_on_ore and ground_tile_data:
			ore_cover += 1

	if newBuilding.require_place_on_ore and ore_cover == 0:
		return false

	return true

func queue_building():
	if not is_valid(current_building): return

	if NetworkHandler.single:
		local_place_queue(current_building, current_rotation)
	else:
		if multiplayer.is_server():
			online_place(select_building, current_building.global_position, current_rotation)
		else:
			online_place.rpc_id(1, select_building, current_building.global_position, current_rotation)
		current_building.queue_free()

	current_building = null

func queue_remove():
	if NetworkHandler.single:
		local_remove_queue(get_global_mouse_position())
	else:
		if multiplayer.is_server():
			online_remove(get_global_mouse_position())
		else:
			online_remove.rpc_id(1, get_global_mouse_position())

func place_building(building: Sprite2D):
	snap(building, building.global_position)
	building.set_place()

@rpc("any_peer", "reliable")
func online_place(cur_building: String, build_pos: Vector2, build_rotation: float):
	if !multiplayer.is_server(): return

	var building: Sprite2D = BUILDING[cur_building].instantiate()
	building.set_sync(true)
	building.building_rotate(build_rotation)
	snap(building, build_pos)

	update_building(building)
	build_global.add_child(building, true)

	if !is_valid(building):
		building.queue_free()
		return

	building.set_queue()

@rpc("any_peer", "reliable")
func online_remove(building_pos: Vector2):
	if !multiplayer.is_server(): return

	for child in build_global.get_children():
		if child.get_global_rect().has_point(building_pos):
			if child.queue:
				child.queue_free()
				return
			else:
				if child.remove:
					child.set_place()
					child.remove = false
				else:
					child.set_remove()

func local_place_queue(building: Sprite2D, build_rotation: float):
	building.reparent(build_global)
	building.building_rotate(build_rotation)
	snap(building, building.global_position)
	update_building(building)
	building.set_queue()

func local_remove_queue(building_pos: Vector2):
	for child in build_global.get_children():
		if child.get_global_rect().has_point(building_pos):
			if child.queue:
				child.queue_free()
				return
			else:
				if child.remove:
					child.set_place()
					child.remove = false
				else:
					child.set_remove()

func set_current_building(build: String):
	if current_building:
		current_building.queue_free()
		current_building = null

	var newBuilding = BUILDING[build].instantiate()
	current_building = newBuilding

	newBuilding.modulate.r = 0.0
	newBuilding.modulate.g = 0.0
	newBuilding.modulate.b = 0.0

	newBuilding.set_sync(false)

	build_preview.add_child(newBuilding)
	snap(newBuilding, get_global_mouse_position())
	update_highlight(newBuilding)
	current_building.building_rotate(current_rotation)

func update_building(building: Sprite2D):
	if building.build_type == "drill":
		if ores_data.size() == 0: return
		var cover = get_cover(building)
		var ore_cover: Dictionary = {}

		for t in cover:
			var ore_tile_coord = ore_tile.get_cell_atlas_coords(t)
			var ground_tile_coord = mineable_ground_tile.get_cell_atlas_coords(t)

			if ore_tile_coord:
				for i in ores_data:
					if i.is_ore_tile and i.atlas == ore_tile_coord:
						if !ore_cover.has(i.ore.name):
							ore_cover[i.ore.name] = [0, i.ore]
						ore_cover[i.ore.name][0] += 1
						break

			if ground_tile_coord:
				for i in ores_data:
					if i.is_ground_tile and i.atlas == ground_tile_coord:
						if !ore_cover.has(i.ore.name):
							ore_cover[i.ore.name] = [0, i.ore]
						ore_cover[i.ore.name][0] += 1
						break

		var max_ore: ResourceType
		var max_count: int = 0
		for ore in ore_cover:
			if ore_cover[ore][0] > max_count:
				max_count = ore_cover[ore][0]
				max_ore = ore_cover[ore][1]

		building.data["Ore"] = max_ore

func _on_gui_building_select(building: String) -> void:
	if BUILDING.has(building):
		select_building = building
		set_current_building(building)
	else:
		if current_building:
			current_building.queue_free()
			current_building = null
