extends Entity
class_name Player

@export var jump_force: float
@export var wall_direction: RayCast2D
@export var wall_timer: Timer
@export var total_wall_time: float = 5.0
var jumps: int = 2
var air_jump: bool = false
var hitted: bool = false
var ragdoll: Ragdoll2D

func init_animations() -> void:
	var geral_factor: Callable = func(): return 1.7
	animation.set_animation("idle", func(): return current_state == State.Idle, 4, geral_factor)
	animation.set_animation("move", func(): return current_state == State.Moving, 4, geral_factor)
	animation.set_animation("jump", func(): return velocity.y <= up_direction.y, 3, geral_factor)
	animation.set_animation("fall", func(): return current_state == State.Falling, 3, geral_factor)
	animation.set_animation("roll", func(): return air_jump, 2, geral_factor, func(): air_jump = false)
	animation.set_animation("wall_right", 
	func(): return is_on_wall_only() && !wall_timer.paused && wall_timer.time_left>0 && current_direction == LookDirection.Right, 
		2, geral_factor)
	animation.set_animation("wall_left", 
	func(): return is_on_wall_only() && !wall_timer.paused && wall_timer.time_left>0 && current_direction == LookDirection.Left, 
		2, geral_factor)
	animation.set_animation("hit", func(): return hitted, 1, func(): return 1, dies)
	animation.set_animation("dead", func(): return current_state == State.Dead, 0, func(): return 1)

func move_behavior(delta:float) -> void:
	super.move_behavior(delta)
	wall_direction.target_position.x = abs(wall_direction.target_position.x)*current_direction
	var direction:Vector2 = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = lerp(velocity.x, direction.x*speed, 0.20) if velocity.x < speed*0.75 else lerp(velocity.x, direction.x*speed, 0.40)
	if is_on_floor() && direction.x == 0:
		current_state = State.Idle

func action_behavior(delta:float) -> void:
	if Input.is_action_just_pressed("down"):
		global_position.y += 3
	jumps = 2 if is_on_floor() else 1 if jumps > 0 else 0
	jump(delta, wall_sliding(delta))

func jump(_delta: float, on_wall: bool = false) -> void:
	if jumps > 0 and Input.is_action_just_pressed("jump"):
		velocity.y = 0
		velocity.y = lerp(up_direction.y*jump_force, 0.0, 0.2)
		jumps -=1
		if on_wall:
			velocity.x = 430*-current_direction
		if !is_on_floor() && !on_wall:
			air_jump = true;

func wall_sliding(delta:float) -> bool:
	wall_direction.force_raycast_update()
	if is_on_floor_only(): 
		wall_timer.start(total_wall_time)
		return false
	wall_timer.paused = true
	var can_grab: bool =  is_on_wall_only() and velocity.x !=0 and velocity.y !=0 and current_state == State.Falling
	if  can_grab and wall_direction.is_colliding():
		wall_timer.paused = false
		if wall_timer.time_left > 0:
			jumps = 1
			velocity.y = (-up_direction.y)*abs(default_gravity-wall_timer.time_left*2)*3*delta
			return true
	return false


func hit(_hit_origin: Vector2 = Vector2.ZERO) -> void:
	if (!hitted):
		hitted = true
		collision.set_deferred("disabled", true)
		has_gravity = false
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		ragdoll = Ragdoll2D.new(collision, sprite, 5, 450, Vector2(rng.randf_range(-150, 150), -250))
		ragdoll.gravity_scale = 0.7
		ragdoll.global_position = global_position
		get_parent().call_deferred("add_child",ragdoll)
		visible = false

	

		
