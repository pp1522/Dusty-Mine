class_name Building
extends Sprite2D


@export var rect: Rect2
@export var build_type: String

@export var build_speed: int = 10
@export var can_rotate: bool = false

@export var can_place_on_ground: bool = true
@export var can_place_on_liquid: bool = false
@export var require_place_on_ore: bool = false

@export var properties: BuildProperties

@onready var ui: Control = $Control

var item: Array[ResourceType] = []
var data: Dictionary = {}

var place: bool = false
var queue: bool = false
var remove: bool = false

func get_global_rect():
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func set_sync(enable: bool):
	var sync = get_node_or_null("MultiplayerSynchronizer")
	if sync:
		if enable:
			sync.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			sync.free()

func set_place():
	modulate.r = 1.0
	modulate.g = 1.0
	modulate.b = 1.0
	modulate.a = 1.0

	place = true
	queue = false

func set_queue():
	modulate.r = 1.0
	modulate.g = 1.0
	modulate.b = 1.0

	queue = true

func set_remove():
	modulate.r = 1.0
	modulate.g = 0.0
	modulate.b = 0.0

	remove = true

func building_rotate(deg: float):
	if can_rotate:
		global_rotation = deg_to_rad(deg)

func toggle_item():
	if ui.visible:
		ui.visible = false
	else:
		ui.visible = true
