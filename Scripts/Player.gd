extends CharacterBody2D

const SPEED := 200.0

@export var moving := false
@export var SyncPos := Vector2.ZERO

@onready var sprite := $AnimatedSprite2D
@onready var overhead_tag: Label = $"overhead tag"
@onready var tooltip: Container = $tooltip

var nickname : String
var message_tween : Tween

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if not is_multiplayer_authority():
		$CollisionShape2D.disabled = true

func _ready() -> void:
	overhead_tag.text = nickname
	tooltip.tooltip_text = nickname
	
func set_message(message: String) -> void:
	overhead_tag.text = message
	
	var base_duration := 1.0
	var per_word := 0.4
	var max_duration := 4.0

	var duration := base_duration + message.split(" ").size() * per_word
	duration = clamp(duration, base_duration, max_duration)
	
	if message_tween and message_tween.is_valid():
		message_tween.kill()
		
	message_tween = create_tween()	
	message_tween.tween_interval(duration)
	message_tween.tween_callback(func(): overhead_tag.text = nickname)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
			
func _physics_process(_delta: float) -> void:
	
	if is_multiplayer_authority() and not get_viewport().gui_get_focus_owner():
		velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * SPEED
		
		moving = velocity != Vector2.ZERO
		
		if velocity.x > 0:
			sprite.flip_h = false
		elif velocity.x < 0:
			sprite.flip_h = true
		
		move_and_slide()
		
		SyncPos = global_position
	else:
		global_position = global_position.lerp(SyncPos, 0.5)
		
	if moving:
		sprite.play("Running")
	else:
		sprite.stop()
