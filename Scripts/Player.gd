extends CharacterBody2D

const SPEED = 200.0

@onready var sprite := $AnimatedSprite2D
@export var moving := false
@export var SyncPos := Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if not is_multiplayer_authority():
		$CollisionShape2D.disabled = true

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
