extends Control
class_name MultiplayerMenu

signal create_server_in_scene_game
signal join_server_in_scene_game(ip: String)
signal set_name_in_scene_game(nickname: String)

const DISCOVERY_PORT = 6767

var udp := PacketPeerUDP.new()

var isServer := false
var isClient := false
var isConnectedAsClient := false

var servers := {}

@onready var servers_list: ItemList = $"Servers Display/MarginContainer/Servers List"
@onready var server_name_input: LineEdit = $"Hosting Group/Server Name/LineEdit"
@onready var player_name: LineEdit = $"Name Selector/Player Name/LineEdit"


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if isServer:
		handle_server_process()
	
	if isClient and not isConnectedAsClient:
		handle_client_process()


func handle_server_process() -> void:
	while udp.get_available_packet_count() > 0:
		var pkt = udp.get_packet()
		var data = pkt.get_string_from_utf8()
		
		if data != "get_server":
			continue
			
		var client_ip = udp.get_packet_ip()
		var client_port = udp.get_packet_port()
		
		udp.set_dest_address(client_ip, client_port)
		udp.put_packet(server_name_input.text.to_utf8_buffer())
		print("yo yo i just responded back to client ", client_ip)


func handle_client_process() -> void:
	while udp.get_available_packet_count() > 0:
		var server_name := udp.get_packet().get_string_from_utf8()
		var ip := udp.get_packet_ip()
		
		if not servers.has(ip):
			print("Found a server ", server_name)
			servers[ip] = true
			var idx = servers_list.add_item(server_name)
			servers_list.set_item_metadata(idx, ip)

var text_input_is_empty_func_tweens : Dictionary = {}
var text_input_is_empty_func_placeholders : Dictionary = {}
func text_input_is_empty(input: LineEdit) -> bool:
	if not input.text.strip_edges().is_empty():
		return false	
	
	if not text_input_is_empty_func_placeholders.has(input):
		text_input_is_empty_func_placeholders[input] = input.placeholder_text
	
	var tween : Tween = text_input_is_empty_func_tweens.get(input)
	
	if tween and tween.is_valid():
		tween.kill()

	tween = create_tween()
	text_input_is_empty_func_tweens[input] = tween
	
	input.placeholder_text = input.placeholder_text.to_upper()
	
	tween.tween_interval(1.0)
	tween.tween_callback(
		func(): 
			if not is_instance_valid(input):
				return
			input.placeholder_text = text_input_is_empty_func_placeholders.get(input)
			text_input_is_empty_func_tweens.erase(input)
			text_input_is_empty_func_placeholders.erase(input)
	)
	
	return true

func _on_create_server_pressed() -> void:
	
	if text_input_is_empty(server_name_input):
		return
	
	if text_input_is_empty(player_name):
		return
	
	udp.close()
	
	udp.bind(DISCOVERY_PORT)
	udp.set_broadcast_enabled(true)	
	isServer = true
	
	set_name_in_scene_game.emit(player_name.text)
	create_server_in_scene_game.emit()
	print("Created Server")


func _on_discover_servers_pressed() -> void:
	isClient = true
	udp.close()
	
	udp.bind(0)
	udp.set_broadcast_enabled(true)	
	udp.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	udp.put_packet("get_server".to_utf8_buffer())
	#create_button.disabled = true
	#discover_button.disabled = true
	
	servers.clear()
	servers_list.clear()
	print("Created Client")


func _on_join_button_pressed() -> void:
	
	if text_input_is_empty(player_name):
		return
		
	var selected := servers_list.get_selected_items()
	if selected.is_empty():
		return
		
	var idx := selected[0]
	var ip = servers_list.get_item_metadata(idx)
	
	join_server_in_scene_game.emit(ip)
	set_name_in_scene_game.emit(player_name.text)
