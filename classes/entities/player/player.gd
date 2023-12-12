extends Entity
class_name Player

@export var jump_force: float
@export var wall_direction: RayCast2D
@export var left_ceiling_cast: RayCast2D
@export var right_ceiling_cast: RayCast2D
@export var wall_timer: Timer
@export var mercy_jump_timer: Timer
@onready var min_jump_speed: float = jump_force*0.75
@onready var max_jump_speed: float = jump_force*2.5
@onready var max_wall_speed: float = 70
var mercy_jump_time: float = 0.1
var max_wall_time: float = 5.0
var max_jump_time: float = 0.2
var jump_time: float = 0.0
var wall_direction_collided: int = 0
var jumps: int = 2
var air_jump: bool = false
 

func _ready() -> void:	
	State.Jumping = State.size()
	State.WallSliding = State.size()
	super._ready()
	slide_on_ceiling = true

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

func move_behavior(delta: float) -> void:
	sprite.flip_h = current_direction == LookDirection.Left
	wall_direction.target_position.x = abs(wall_direction.target_position.x)*current_direction
	var direction:Vector2 = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	current_direction = 1 if velocity.x > 0 else -1 if velocity.x < 0 else current_direction
	velocity.x = lerp(velocity.x, direction.x*speed, clamp(delta*acceleration, 0, 1.0))
	if is_on_floor():
		current_state = State.Idle if direction.x == 0 || is_on_wall() else State.Moving
		mercy_jump_timer.start(mercy_jump_time)
		wall_timer.start(max_wall_time)
		jumps = 2
	elif velocity.y < up_direction.y:
		current_state = State.Jumping
	elif velocity.y > -up_direction.y:
		current_state = State.Falling

func state_behavior() -> void:
	super.state_behavior()
	wall_timer.paused = true
	match(current_state):
		State.Jumping:
			if left_ceiling_cast.is_colliding():
				global_position.x+=3
			if right_ceiling_cast.is_colliding():
				global_position.x-=3
		State.WallSliding:
			mercy_jump_timer.start(mercy_jump_time)
			wall_timer.paused = false

func action_behavior(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		global_position.y += 3
	wall_sliding(delta)
	jump_on_tap()
	jump_on_hold(delta)

func jump_on_tap() -> void:
	if Input.is_action_just_pressed("jump"):
		if jumps>0:
			if mercy_jump_timer.is_stopped():
				jumps = 1
			air_jump = jumps == 1
			jump_time = max_jump_time
			velocity.y = min_jump_speed*up_direction.y
			jumps-=1
		elif !mercy_jump_timer.is_stopped():
			var can_wall_jump: bool = Input.is_action_pressed("ui_right") if wall_direction_collided == -1\
			 else Input.is_action_pressed("ui_left") if wall_direction_collided == 1 else false
			if can_wall_jump:
				if wall_timer.time_left-1 < 0: wall_timer.stop()
				else: wall_timer.start(wall_timer.time_left-1)
				velocity.y = min_jump_speed*1.5*up_direction.y
				velocity.x = speed*0.5*-wall_direction_collided
				
##After jump, can hold the jump up to 0.2 seconds. The jump final velocity will be the same in any framerate, 
##this is why this function dont use [Timer] to handle delta.
func jump_on_hold(delta: float) -> void:
	if jump_time>0:
		if Input.is_action_pressed("jump"):
			jump_time = jump_time-delta
			delta += jump_time if jump_time<0 else 0.0
			var jump_step: float = jump_force*delta*(1+max_jump_speed/min_jump_speed)
			velocity.y += jump_step*up_direction.y
		else: 
			jump_time = 0
	
func wall_sliding(delta: float) -> void:
	wall_direction.force_raycast_update()
	var can_grab: bool =  is_on_wall_only() and velocity.x !=0 and velocity.y !=0 and current_state == State.Falling\
	 and wall_direction.is_colliding() and !wall_timer.is_stopped()
	if  can_grab:
		velocity.y = clampf(velocity.y-max_wall_speed*2*delta-abs(gravity_step), max_wall_speed-abs(gravity_step), max_wall_speed*2)
		jumps = 0
		current_state = State.WallSliding
		wall_direction_collided = current_direction
			

func hit(_sender: Node2D, offset: Vector2) -> void:
	if current_state != State.Hitted:
		current_state = State.Hitted
		life_points = 0
		spawn_ragdoll(offset)

func dies(_sender: Node2D = null, _offset: Vector2 = Vector2.ZERO) -> void:
	super.dies()
	

func debug_status() -> void:
	debug_label.text += str("\n", velocity.x)
