extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var playerScene: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MultiplayerSpawner.spawn_function = _spawnPlayer

func _on_host_pressed() -> void:
	peer.create_server(7777)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	$CanvasLayer.visible = false
	
	_add_player() # lemme just add myself lol

func _on_join_pressed() -> void:
	peer.create_client("localhost", 7777)
	multiplayer.multiplayer_peer = peer
	
	$CanvasLayer.visible = false
	
func _add_player(id = 1):
	#var player = playerScene.instantiate()
	#player.name = str(id)
	var pos := get_viewport_rect().size / 2
	#call_deferred("add_child", player)
	
	$MultiplayerSpawner.spawn({ "id": id, "pos": pos })
	
func _spawnPlayer(data):
	var player = playerScene.instantiate()
	player.name = str(data.id)
	player.position = data.pos
	return player
