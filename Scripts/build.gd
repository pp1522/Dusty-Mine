extends Node2D


const BUILDING = {
	"drill": preload("res://Object/building/drill.tscn"),
	"belt": preload("res://Object/building/belt.tscn")
}

@export var TILE_SIZE: Vector2i = Vector2i(32, 32)
@export var liquid_tile: TileMapLayer
@export var ground_tile: TileMapLayer
@export var mineable_ground_tile: TileMapLayer
@export var ore_tile: TileMapLayer

var current_building
var old_pos: Vector2
var building_object: PackedScene
var current_rotation: float = 0.0


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("place") and current_building:
		place_building()

	elif Input.is_action_just_pressed("remove") and current_building:
		current_building.queue_free()
		current_building = null

	elif Input.is_action_just_pressed("remove"):
		remove_building()

	elif Input.is_action_just_pressed("rotate") and current_building:
		current_rotation = wrapf(current_rotation+90.0, 0.0, 360.0)
		current_building.building_rotate(current_rotation)

func _process(_delta: float) -> void:
	if current_building:
		snap(current_building)

func update_highlight(newBuilding):
	if is_valid():
		newBuilding.modulate.r = 0.0
		newBuilding.modulate.g = 1.0
	else:
		newBuilding.modulate.r = 1.0
		newBuilding.modulate.g = 0.0

func snap(newBuilding: Sprite2D):
	newBuilding.global_position = get_global_mouse_position() - TILE_SIZE/2.0

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

func is_valid():
	var intersects = []

	# building
	for child in get_children():
		if child.get_global_rect().intersects(current_building.get_global_rect()):
			intersects.append(child)

	if intersects.size() != 1: return false

	var cover = get_cover(current_building)

	# tile stuff
	var ore_cover = 0
	for t in cover:
		var tile_data = ground_tile.get_cell_tile_data(t)
		var liquid_tile_data = liquid_tile.get_cell_tile_data(t)
		var ore_tile_data = ore_tile.get_cell_tile_data(t)
		var ground_tile_data = mineable_ground_tile.get_cell_tile_data(t)

		if not current_building.can_place_on_ground and tile_data:
			return false

		if not current_building.can_place_on_liquid and liquid_tile_data:
			return false

		if current_building.require_place_on_ore and ore_tile_data:
			ore_cover += 1

		if current_building.require_place_on_ore and ground_tile_data:
			ore_cover += 1


	if current_building.require_place_on_ore and ore_cover == 0:
		return false

	return true

func place_building():
	if not is_valid(): return
	current_building.place()

	snap(current_building)

	current_building = null

func remove_building():
	var pos = get_global_mouse_position()

	for child in get_children():
		if child.get_global_rect().has_point(pos):
			child.queue_free()
			return

func _on_gui_building_select(building: String) -> void:
	if BUILDING.has(building) and current_building == null:
		var newBuilding = BUILDING[building].instantiate()
		current_building = newBuilding

		newBuilding.modulate.r = 0.0
		newBuilding.modulate.g = 0.0
		newBuilding.modulate.b = 0.0

		add_child(newBuilding)
		snap(newBuilding)
		update_highlight(newBuilding)
		current_building.building_rotate(current_rotation)
	else:
		if current_building:
			current_building.queue_free()
			current_building = null
