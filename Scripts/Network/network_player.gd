class_name NetworkPlayer
extends Node2D


signal click_event(pos: Vector2)

@export var speed: int = 10
@export var player_speed: int = 250
@export var player_radius: int = 10
@export var zoom_speed: float = 0.05

@export var max_zoom: float = 3.0
@export var min_zoom: float = 1.0

@export var camera: Camera2D
@export var player: CharacterBody2D

@export var player_id: int = 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

var vel: Vector2 = Vector2.ZERO

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func get_input():
	var direction = %InputSynchronizer.input_dir
	vel = direction * speed

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		get_input()
		camera.position += vel

		if %InputSynchronizer.zoom_in:
			var z = minf(camera.zoom.x + zoom_speed, max_zoom)
			camera.zoom = Vector2(z, z)

		if %InputSynchronizer.zoom_out:
			var z = maxf(camera.zoom.x - zoom_speed, min_zoom)
			camera.zoom = Vector2(z, z)

		player.velocity = player.position.direction_to(camera.position) * player_speed

		player.look_at(camera.position)
		if player.position.distance_to(camera.position) > player_radius:
			player.move_and_slide()

func mouse_click():
	request_inventory.rpc_id(1, get_global_mouse_position())

@rpc("any_peer", "call_local", "reliable")
func request_inventory(pos: Vector2) -> void:
	click_event.emit(pos)
