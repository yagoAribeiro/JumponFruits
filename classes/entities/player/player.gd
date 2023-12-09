extends Entity
class_name Player

@export var jump_force: float
@export var wall_direction: RayCast2D
@export var wall_timer: Timer
@export var total_wall_time: float = 5.0
const max_jump_ticks: int = 10
var jumps: int = 2
var air_jump: bool = false
var jump_ticks: int = max_jump_ticks

func _ready() -> void:	
	State.Jumping = State.size()
	State.WallSliding = State.size()
	super._ready()

func init_animations() -> void:
	var geral_factor: Callable = func() -> float: return 1.7
	animation.set_animation("idle", func() -> bool: return current_state == State.Idle, 5, geral_factor)
	animation.set_animation("move", func() -> bool: return current_state == State.Moving, 5, geral_factor)
	animation.set_animation("jump", func() -> bool: return current_state == State.Jumping, 4, geral_factor)
	animation.set_animation("fall", func() -> bool: return current_state == State.Falling, 4, geral_factor)
	animation.set_animation("roll", func() -> bool: return air_jump, 3, geral_factor, func() -> void: air_jump = false)
	animation.set_animation("wall_right", 
	func() -> bool: return current_state == State.WallSliding && current_direction == LookDirection.Right, 
		2, geral_factor)
	animation.set_animation("wall_left", 
	func() -> bool: return current_state == State.WallSliding && current_direction == LookDirection.Left, 
		2, geral_factor)
	animation.set_animation("hit", func() -> bool: return current_state == State.Hitted, 1, func() -> float: return 1, dies)
	animation.set_animation("dead", func() -> bool: return current_state == State.Dead, 0, func() -> float: return 1)

func move_behavior(_delta: float) -> void:
	sprite.flip_h = current_direction == LookDirection.Left
	wall_direction.target_position.x = abs(wall_direction.target_position.x)*current_direction
	var direction:Vector2 = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	current_direction = 1 if velocity.x > 0 else -1 if velocity.x < 0 else current_direction
	velocity.x = lerp(velocity.x, direction.x*speed, 0.20) if velocity.x < speed*0.75 else lerp(velocity.x, direction.x*speed, 0.40)
	if is_on_floor():
		current_state = State.Idle if direction.x == 0 else State.Moving
	elif velocity.y < up_direction.y:
		current_state = State.Jumping
	elif velocity.y > -up_direction.y:
		current_state = State.Falling

func action_behavior(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		global_position.y += 3
	jumps = 2 if is_on_floor() else 1 if jumps > 0 else 0
	wall_sliding(delta)
	jump_on_tap()
	jump_on_hold()

func jump_on_tap() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_ticks = max_jump_ticks
		if !is_on_floor() && jumps < 2:
			air_jump = true
		jump(jump_force)	
		jumps -= 1

func jump_on_hold() -> void:
	if Input.is_action_pressed("jump"):
		jump(jump_force)	

func jump(power: float) -> void:
	if jumps<=0 || jump_ticks<=0: return
	velocity.y = 0.0 if jump_ticks >= max_jump_ticks else velocity.y
	if air_jump:
		velocity.y -= power
	else:
		velocity.y -= power*0.75 if jump_ticks >= max_jump_ticks else power*0.05
	jump_ticks -=1
	if current_state == State.WallSliding:
		velocity.x = 430*-current_direction	

func wall_sliding(delta: float) -> void:
	wall_direction.force_raycast_update()
	if is_on_floor_only(): 
		wall_timer.start(total_wall_time)
		return 
	wall_timer.paused = true
	var can_grab: bool =  is_on_wall_only() and velocity.x !=0 and velocity.y !=0 and current_state == State.Falling
	if  can_grab and wall_direction.is_colliding():
		wall_timer.paused = false
		if wall_timer.time_left > 0:
			jumps = 1
			velocity.y = (-up_direction.y)*abs(default_gravity-wall_timer.time_left*2)*3*delta
			current_state = State.WallSliding

func hit(_sender: Node2D, offset: Vector2) -> void:
	if current_state != State.Hitted:
		current_state = State.Hitted
		life_points = 0
		spawn_ragdoll(offset)

func dies(_sender: Node2D = null, _offset: Vector2 = Vector2.ZERO) -> void:
	super.dies()
	

		
