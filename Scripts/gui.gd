extends Control


signal building_select(building)


func _on_building_select(building: Variant) -> void:
	building_select.emit(building)
