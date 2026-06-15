extends Node


const IP_ADDRESS: String = "localhost"
const PORT: int = 34580


var network_player = preload("res://Object/network_player.tscn")
var host: bool = false
var join: bool = false
var single: bool = false
var players_node: Node2D

func start_single() -> void:
	print("Single Player!")

	var single_peer = OfflineMultiplayerPeer.new()
	multiplayer.multiplayer_peer = single_peer

func start_server() -> void:
	print("Host!")

	players_node = get_tree().current_scene.get_node("Player")

	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer

	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)

	_remove_single_player()
	_add_player(1)

func start_client() -> void:
	print("Join!")

	players_node = get_tree().current_scene.get_node("Player")

	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = client_peer

	_remove_single_player()

func _add_player(id: int):
	var new_player = network_player.instantiate()
	new_player.player_id = id
	new_player.name = str(id)

	players_node.add_child(new_player, true)

	var building = get_tree().current_scene.get_node("Building")
	new_player.click_event.connect(building._on_player_click_event)
	new_player.click_remove_event.connect(building._on_player_click_remove_event)

func _remove_player(id: int):
	if not players_node.has_node(str(id)): return
	players_node.get_node(str(id)).queue_free()

func _remove_single_player():
	var single_player = players_node.get_node("PlayerSingle")
	single_player.queue_free()
