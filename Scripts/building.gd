extends Sprite2D


@export var rect: Rect2

@export var build_speed: int = 10
@export var can_rotate: bool = false

@export var can_place_on_ground: bool = true
@export var can_place_on_liquid: bool = false
@export var require_place_on_ore: bool = false

var remove: bool = false

func get_global_rect():
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func place():
	modulate.r = 1.0
	modulate.g = 1.0
	modulate.b = 1.0
	modulate.a = 1.0

func building_rotate(deg: float):
	if can_rotate:
		global_rotation = deg_to_rad(deg)
