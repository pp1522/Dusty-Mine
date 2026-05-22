extends CharacterBody2D


@export var speed = 250
@export var radius = 10
@export var camera: Camera2D

func _physics_process(_delta: float) -> void:
	if camera == null: return
	velocity = position.direction_to(camera.position) * speed

	look_at(camera.position)
	if position.distance_to(camera.position) > radius:
		move_and_slide()
