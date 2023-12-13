extends PatrolEnemy
class_name Mushroom

@export var floor_raycast: RayCast2D


func init_animations() -> void:
	var geral_factor: Callable = func() -> float: return 1.0
	animation.set_animation(
		"idle",
		func() -> bool: return current_state == State.Idle,
		1,
		geral_factor,
		change_direction
	)
	animation.set_animation(
		"move", func() -> bool: return current_state == State.Moving || velocity.x != 0, 1, geral_factor
	)
	animation.set_animation(
		"hit", func() -> bool: return current_state == State.Dead, 0, geral_factor, func()-> void: queue_free()
	)


func move_behavior(delta: float) -> void:
	sprite.flip_h = current_direction == LookDirection.Right
	floor_raycast.position.x = current_direction * 14
	floor_raycast.force_raycast_update()
	if is_on_floor():
		if is_on_wall() || !floor_raycast.is_colliding():
			velocity.x = 0
			current_state = State.Idle
	else: current_state = State.Falling
	if current_state == State.Moving || current_state == State.Falling:
		velocity.x = lerp(velocity.x, current_direction * speed, delta*acceleration)

func hit(sender: Node2D, offset: Vector2) -> void:
	if sender is Player:
		(sender as Player).jumps = 1
		sender.velocity.y = -500
	super.hit(sender, offset)


func dies(_sender: Node2D = null, offset: Vector2 = Vector2.ZERO) -> void:
	super.dies()
	spawn_ragdoll(offset)
	
