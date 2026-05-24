extends Node2D


const OBJECT = preload("res://Object/building/belt.tscn")

@export var TILE_SIZE: Vector2i = Vector2i(32, 32)

var current_building
var old_pos: Vector2


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("place") and not current_building:
		var newBuilding = OBJECT.instantiate()
		current_building = newBuilding

		newBuilding.modulate.r = 0.0
		newBuilding.modulate.g = 0.0
		newBuilding.modulate.b = 0.0

		add_child(newBuilding)
		snap(newBuilding)
		update_highlight(newBuilding)

	elif Input.is_action_just_pressed("place"):
		place_building()

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
	newBuilding.global_position = newBuilding.global_position.snapped(TILE_SIZE) + TILE_SIZE/2.0

	if newBuilding.global_position != old_pos:
		old_pos = newBuilding.global_position
		update_highlight(newBuilding)

func is_valid():
	var valid = true

	var intersects = []

	for child in get_children():
		if child.get_global_rect().intersects(current_building.get_global_rect()):
			intersects.append(child)

	var object_size = (current_building.rect.size.x / TILE_SIZE.x) * (current_building.rect.size.y / TILE_SIZE.y)

	if object_size != intersects.size():
		valid = false

	return valid

func place_building():
	if not is_valid(): return
	current_building.place()

	snap(current_building)

	current_building = null
