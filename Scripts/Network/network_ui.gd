extends Control


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_host_pressed() -> void:
	NetworkHandler.host = true
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_join_pressed() -> void:
	NetworkHandler.join = true
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
