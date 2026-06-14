class_name SinglePlayer
extends Node2D


signal click_event(pos: Vector2, build_rotation: float, building: String)
signal click_remove_event(pos: Vector2)

@export var speed: int = 10
@export var player_speed: int = 250
@export var player_radius: int = 10
@export var zoom_speed: float = 0.05

@export var max_zoom: float = 3.0
@export var min_zoom: float = 1.0

@export var camera: Camera2D
@export var player: CharacterBody2D

@export var build: Build

var vel = Vector2.ZERO
var select_building: String = ""
var current_building: Building
var current_rotation: float = 0.0

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	vel = direction * speed

func _process(_delta: float) -> void:
	if current_building:
		build.snap(current_building, get_global_mouse_position())
	elif select_building:
		set_current_building(select_building)

func _physics_process(_delta: float) -> void:
	get_input()
	camera.position += vel

	player.velocity = player.position.direction_to(camera.position) * player_speed

	player.look_at(camera.position)
	if player.position.distance_to(camera.position) > player_radius:
		player.move_and_slide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("zoom in"):
		var z = minf(camera.zoom.x + zoom_speed, max_zoom)
		camera.zoom = Vector2(z, z)

	if Input.is_action_just_pressed("zoom out"):
		var z = maxf(camera.zoom.x - zoom_speed, min_zoom)
		camera.zoom = Vector2(z, z)

	if Input.is_action_just_pressed("place"):
		click_event.emit(get_global_mouse_position(), current_rotation, select_building)

	if Input.is_action_just_pressed("remove") and current_building:
		current_building.queue_free()
		current_building = null
		select_building = ""

	elif Input.is_action_just_pressed("remove"):
		click_remove_event.emit(get_global_mouse_position())

	if Input.is_action_just_pressed("rotate") and current_building:
		current_rotation = wrapf(current_rotation+90.0, 0.0, 360.0)
		current_building.building_rotate(current_rotation)

func set_current_building(building: String):
	if current_building:
		current_building.queue_free()
		current_building = null

	var newBuilding = build.BUILDING[building].instantiate()
	current_building = newBuilding

	newBuilding.modulate.r = 0.0
	newBuilding.modulate.g = 0.0
	newBuilding.modulate.b = 0.0

	newBuilding.set_sync(false)

	add_child(newBuilding)
	build.snap(newBuilding, get_global_mouse_position())
	build.update_highlight(newBuilding)
	current_building.building_rotate(current_rotation)

func _on_gui_building_select(building: String) -> void:
	select_building = building
	if current_building:
		current_building.queue_free()
		current_building = null
