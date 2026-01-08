extends CharacterBody2D

const SPEED = 25000.0

@onready var sprite := $AnimatedSprite2D
@export var moving := false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * delta * SPEED
	
		if velocity == Vector2.ZERO:
			sprite.stop()
			moving = false
		else:
			moving = true
			sprite.play("Running")	
		
		move_and_slide()
	else: 
		if moving:
			sprite.play("Running")
		else:
			sprite.stop()
