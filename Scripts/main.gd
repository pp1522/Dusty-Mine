extends Node2D


@onready var building: Build = $Building
@onready var builds: Node2D = $Building/Build

@onready var terrain: TerrainGen = $Tiles

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

			if child.data["tick"] >= child.properties.speed:
				child.data["tick"] = 0
				if (child.data["Ore"] and
					child.item.size() < child.properties.storage
				):
					child.item.append(child.data["Ore"])

				var cover = building.get_cover(child)
				for t in cover:
					var build_arround = building.get_building_around(t)
					for b in build_arround:
						if child.item.size() == 0: break
						if b.build_type == "belt":
							if b.item.size() >= b.properties.storage: continue
							b.item.append(child.item[0])
							child.item.remove_at(0)

		elif child.build_type == "belt":
			if !child.data.has("Belt_Target"): return
			if child.data["Belt_Target"].size() == 0: return

			if !child.data.has("tick"): child.data["tick"] = 0
			child.data["tick"] += 1

			for b in child.data["Belt_Target"]:
				if !is_instance_valid(b):
					child.data["Belt_Target"].erase(b)
					return

				if child.data["tick"] >= child.properties.speed:
					child.data["tick"] = 0

					if (child.item.size() == 0 or
						b.item.size() >= b.properties.storage
					):
						return

					b.item.append(child.item[0])
					child.item.remove_at(0)
