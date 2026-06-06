extends Node2D


signal get_inventory_data(pos: Vector2)

@export var speed: int = 10
@export var player_speed: int = 250
@export var player_radius: int = 10
@export var zoom_speed: float = 0.05

@export var max_zoom: float = 3.0
@export var min_zoom: float = 1.0

@export var camera: Camera2D
@export var player: CharacterBody2D

var vel = Vector2.ZERO

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	vel = direction * speed

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
		var pos = get_global_mouse_position()
		get_inventory_data.emit(pos)
