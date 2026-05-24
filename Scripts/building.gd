extends Sprite2D


@export var rect: Rect2

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
