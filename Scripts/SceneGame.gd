extends Node2D

const GAME_PORT = 5555

var peer = ENetMultiplayerPeer.new()

@export var playerScene: PackedScene
@onready var multiplayer_menu: MultiplayerMenu = $"CanvasLayer/Multiplayer Menu"
@onready var touch_screen_joystick: TouchScreenJoystick = $CanvasLayer/TouchScreenJoystick
@onready var chat_interface: Control = $CanvasLayer/ChatInterface


func _ready() -> void:
	
	touch_screen_joystick.visible = DisplayServer.is_touchscreen_available()
	chat_interface.hide()
	
	$MultiplayerSpawner.spawn_function = _spawnPlayer
	
	multiplayer_menu.create_server_in_scene_game.connect(create_server)
	multiplayer_menu.join_server_in_scene_game.connect(join_server)


func create_server() -> void:	
	peer.create_server(GAME_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	multiplayer_menu.hide()
	chat_interface.show()
	
	_add_player()


func join_server(ip: String) -> void:
	peer.create_client(ip, GAME_PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer_menu.isConnectedAsClient = true
	
	multiplayer.connected_to_server.connect(
		func():
			print("Connected to server")
			multiplayer_menu.hide()
			chat_interface.show()
	)
	
	multiplayer.connection_failed.connect(
		func():
			print("Connection failed bro")
	)


func _add_player(id = 1):
	var pos := get_viewport_rect().size / 2
	$MultiplayerSpawner.spawn({ "id": id, "pos": pos })
	
	
func _spawnPlayer(data):
	var player = playerScene.instantiate()
	player.name = str(data.id)
	player.position = data.pos
	return player
