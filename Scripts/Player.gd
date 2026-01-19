extends CharacterBody2D

const SPEED := 200.0
# 10ms per character in message
const DURATION_PER_CHAR := 0.3

@export var moving := false
@export var SyncPos := Vector2.ZERO

@onready var sprite := $AnimatedSprite2D
@onready var overhead_tag: Label = $"overhead tag"
@onready var tooltip: Container = $tooltip

var nickname : String

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if not is_multiplayer_authority():
		$CollisionShape2D.disabled = true

func _ready() -> void:
	overhead_tag.text = nickname
	tooltip.tooltip_text = nickname
	
func set_message(message: String) -> void:
	overhead_tag.text = message
	get_tree().create_timer(message.length() * DURATION_PER_CHAR).timeout.connect(
		func() -> void:
			overhead_tag.text = nickname
	)
	
func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
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
