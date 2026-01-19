extends Node2D

const GAME_PORT = 5555

var peer = ENetMultiplayerPeer.new()
var own_name : String

@export var playerScene: PackedScene
@onready var multiplayer_menu: MultiplayerMenu = $"CanvasLayer/Multiplayer Menu"
@onready var touch_screen_joystick: TouchScreenJoystick = $CanvasLayer/TouchScreenJoystick
@onready var chat_interface: ChatInterface = $CanvasLayer/ChatInterface

func _ready() -> void:
	
	touch_screen_joystick.visible = DisplayServer.is_touchscreen_available()
	chat_interface.hide()
	
	$MultiplayerSpawner.spawn_function = _spawnPlayer
	
	multiplayer_menu.create_server_in_scene_game.connect(create_server)
	multiplayer_menu.join_server_in_scene_game.connect(join_server)
	
	multiplayer_menu.set_name_in_scene_game.connect(
		func(val):
			chat_interface.own_name = val
			own_name = val
	)
	
	chat_interface.message_recieved.connect(_message_recieved)
	
func create_server() -> void:	
	peer.create_server(GAME_PORT)
	multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(_add_player)
	
	multiplayer_menu.hide()
	chat_interface.show()
	
	add_player(1, own_name)


func join_server(ip: String) -> void:
	peer.create_client(ip, GAME_PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer_menu.isConnectedAsClient = true
	
	multiplayer.connected_to_server.connect(
		func():
			print("Connected to server")
			rpc_id(1, "send_player_data", own_name)
			multiplayer_menu.hide()
			chat_interface.show()
	)
	
	multiplayer.connection_failed.connect(
		func():
			print("Connection failed bro")
	)

@rpc("any_peer", "call_remote", "reliable")
func send_player_data(nickname: String) -> void:
	var senderID := multiplayer.get_remote_sender_id()
	add_player(senderID, nickname)

func _message_recieved(senderID: int, message: String) -> void:
	var player := get_node_or_null(str(senderID))
	if player:
		player.set_message(message)

func add_player(id : int, nickname: String) -> void:
	var pos := get_viewport_rect().size / 2
	$MultiplayerSpawner.spawn({ "id": id, "pos": pos, "nickname": nickname })
	
func _spawnPlayer(data):
	var player = playerScene.instantiate()
	player.name = str(data.id)
	player.nickname = data.nickname
	player.position = data.pos
	return player
