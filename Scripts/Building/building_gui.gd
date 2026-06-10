extends Control


signal select(building)

@export var button: Array[BuildingButton]

@export var button_grid: Vector2i = Vector2i(2, 3)
@export var button_size: float = 32
@export var button_offset: float = 24

func _ready():
	select.emit("")

	var button_pos: Vector2i = Vector2i(0, 0)
	var button_scale: Vector2 = Vector2(
		(size.x-button_offset*(button_grid.x+1))/button_grid.x,
		(size.y-button_offset*(button_grid.y+1))/button_grid.y)
	for b in button:
		var button_node = Button.new()
		button_node.name = b.name
		button_node.icon = b.image

		button_node.size.x = b.size.x*button_size + 8
		button_node.size.y = b.size.y*button_size + 8
		button_node.position.x = button_pos.x*(button_scale.x+button_offset)+button_offset
		button_node.position.y = button_pos.y*(button_scale.y+button_offset)+button_offset

		button_node.scale.x = button_scale.x/(b.size.x*button_size+8)
		button_node.scale.y = button_scale.y/(b.size.y*button_size+8)

		button_node.pressed.connect(button_press.bind(button_node))

		add_child(button_node)

		button_pos.x += 1
		if button_pos.x >= button_grid.x:
			button_pos.x = 0
			button_pos.y += 1

func button_press(b: Button):
	select.emit(b.name)
