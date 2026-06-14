extends MultiplayerSynchronizer


@onready var player: Node2D = $".."

var input_dir: Vector2
var zoom_in: bool
var zoom_out: bool

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

	input_dir = Input.get_vector("left", "right", "up", "down")
	zoom_in = Input.is_action_just_pressed("zoom in")
	zoom_out = Input.is_action_just_pressed("zoom out")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place"):
		player.mouse_click()

	if event.is_action_pressed("remove"):
		player.build_remove()

	if event.is_action_pressed("rotate"):
		player.build_rotate()

func _physics_process(_delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	zoom_in = Input.is_action_just_pressed("zoom in")
	zoom_out = Input.is_action_just_pressed("zoom out")
