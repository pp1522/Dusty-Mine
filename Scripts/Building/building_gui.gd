extends Control


signal select(building)

@export var button: Array[BuildingButton]

@export var button_per_row: int = 2
@export var button_size: int = 32
@export var button_scale: int = 2
@export var button_offset: int = 24

func _ready():
	select.emit("")

	var button_pos: Vector2i = Vector2i(0, 0)
	var button_pos_mul = button_size*button_scale + button_offset
	for b in button:
		var button_node = Button.new()
		button_node.name = b.name
		button_node.icon = b.image

		button_node.size.x = b.size.x*button_size + 8
		button_node.size.y = b.size.y*button_size + 8
		button_node.position.x = button_pos.x * button_pos_mul + button_offset
		button_node.position.y = button_pos.y * button_pos_mul + button_offset

		button_node.scale.x = float(button_size)/(b.size.x*button_size+8)*button_scale
		button_node.scale.y = float(button_size)/(b.size.y*button_size+8)*button_scale

		button_node.pressed.connect(button_press.bind(button_node))

		add_child(button_node)

		button_pos.x += 1
		if button_pos.x >= button_per_row:
			button_pos.x = 0
			button_pos.y += 1

func button_press(b: Button):
	select.emit(b.name)
