class_name Items
extends Control


@export var resources: Dictionary[ResourceType, int] = {}

# Hmm I have seen this before...
@export var item_size: float = 32.0
@export var item_scale: float = 2
@export var item_offset: int = 0

@onready var items: Control = $Items

func _ready() -> void:
	update_item()

func update_item():
	for i in items.get_children():
		i.queue_free()

	var x = 0
	for r in resources:
		var item = TextureRect.new()
		item.name = r.name
		item.texture = r.image

		item.size.x = 40
		item.size.y = 40
		item.position.x = x
		item.position.y = item_offset

		item.scale.x = item_size/40*item_scale
		item.scale.y = item_size/40*item_scale

		items.add_child(item)

		x += 40 + item_offset
