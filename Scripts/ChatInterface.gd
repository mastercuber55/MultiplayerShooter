extends Control

var own_name : String = str(randf())

@onready var display: TextEdit = $Display
@onready var input: LineEdit = $Input
@onready var send_button: Button = $"Send Button"

func _on_send_button_pressed() -> void:
	if input.text.begins_with("/nick"):
		var new_name = input.text.substr("/nick".length())
		update_name(own_name, new_name)
		
	rpc("add_message", own_name, input.text)
	input.text = ""

@rpc("any_peer", "call_local")
func add_message(sender: String, message: String) -> void:
	display.text += str(sender, ":", message, "\n")
	display.scroll_vertical = INF

func update_name(old_own_name: String, new_own_name: String) -> void:
	rpc("add_message", "System", str(old_own_name, " changed their name to ", new_own_name))
	own_name = new_own_name
