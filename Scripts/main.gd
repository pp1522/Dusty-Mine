extends Node2D


func _ready() -> void:
	if NetworkHandler.host:
		NetworkHandler.start_server()
	elif NetworkHandler.join:
		NetworkHandler.start_client()
	elif NetworkHandler.single:
		NetworkHandler.start_single()
