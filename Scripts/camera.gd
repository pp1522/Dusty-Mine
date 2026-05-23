extends Camera2D


@export var speed = 10
@export var zoom_speed = 0.05

@export var max_zoom = 3.0
@export var min_zoom = 1.0

var vel = Vector2.ZERO

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	vel = direction * speed

func _physics_process(_delta: float) -> void:
	get_input()
	position += vel

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("zoom in"):
		var z = minf(zoom.x + zoom_speed, max_zoom)
		zoom = Vector2(z, z)

	if Input.is_action_just_pressed("zoom out"):
		var z = maxf(zoom.x - zoom_speed, min_zoom)
		zoom = Vector2(z, z)
