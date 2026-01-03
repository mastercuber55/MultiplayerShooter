extends CharacterBody2D

const SPEED = 25000.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * delta * SPEED
	move_and_slide()
