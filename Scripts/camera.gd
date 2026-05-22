extends Camera2D


@export var speed = 10

var vel = Vector2.ZERO

func get_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	vel = direction * speed

func _physics_process(_delta: float) -> void:
	get_input()
	position += vel
