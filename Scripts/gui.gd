extends Control


signal building_select(building)

@export var button: Array[Button]

func _ready():
	building_select.emit("")

	for b:Button in button:
		b.pressed.connect(button_press.bind(b))

func button_press(b: Button):
	building_select.emit(b.name)
