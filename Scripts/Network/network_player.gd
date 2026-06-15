class_name NetworkPlayer
extends Node2D


signal click_event(pos: Vector2)
signal click_remove_event(pos: Vector2)

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
var select_building: String = ""
var current_building: Building
var current_rotation: float = 0.0

var build: Build

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		var gui = get_tree().current_scene.get_node("CanvasLayer").get_node("Gui")
		gui.building_select.connect(_on_gui_building_select)
		build = get_tree().current_scene.get_node("Building")

		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _process(_delta: float) -> void:
	if current_building:
		build.snap(current_building, get_global_mouse_position())
	elif select_building:
		set_current_building(select_building)

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

func mouse_click():
	fire_click_evnet.rpc_id(1, get_global_mouse_position(), select_building)

func build_remove():
	if current_building:
		current_building.queue_free()
		current_building = null
		select_building = ""
	else:
		click_remove_event.emit(get_global_mouse_position())

func build_rotate():
	if current_building:
		current_rotation = wrapf(current_rotation+90.0, 0.0, 360.0)
		current_building.building_rotate(current_rotation)

@rpc("any_peer", "call_local", "reliable")
func fire_click_evnet(pos: Vector2, building: String) -> void:
	click_event.emit(pos, current_rotation, building)

func _on_gui_building_select(building: String) -> void:
	select_building = building
	if current_building:
		current_building.queue_free()
		current_building = null
