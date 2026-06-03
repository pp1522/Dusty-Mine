extends Node2D


@onready var building: Building = $Building
@onready var builds: Node2D = $Building/Build

func _ready() -> void:
	if NetworkHandler.host:
		NetworkHandler.start_server()
	elif NetworkHandler.join:
		NetworkHandler.start_client()
	elif NetworkHandler.single:
		NetworkHandler.start_single()

func _process(_delta: float) -> void:
	for child in builds.get_children():
		if !(child.place and !child.remove): return
		if child.build_type == "drill":
			if child.properties.type != "drill": return
			if !child.data.has("tick"): child.data["tick"] = 0
			child.data["tick"] += 1

			if child.data["tick"] == child.properties.speed:
				if (child.data["Ore"] and
					child.item.size() < child.properties.storage
				):
					child.item.append(child.data["Ore"])

				child.data["tick"] = 0

func get_building_around(cur_pos: Vector2i):
	var builds: Array[Sprite2D] = []

	var dirs = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]

	for d in dirs:
		var pos = cur_pos+d
		if building.building_tile.has(pos):
			builds.append(building.building_tile[pos])

	return builds
