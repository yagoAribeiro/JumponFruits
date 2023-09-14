extends Entity
class_name Player

@export var jump_force: float
@export var wall_direction: RayCast2D
@export var wall_timer: Timer
@export var total_wall_time: float = 5.0
var jumps: int = 2

func move_behavior(delta:float) -> void:
	super.move_behavior(delta)
	wall_direction.target_position.x = abs(wall_direction.target_position.x)*current_direction
	var direction:Vector2 = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = lerp(velocity.x, direction.x*speed, 0.25)

func action_behavior(delta:float) -> void:
	jumps = 2 if is_on_floor() else 1 if jumps > 0 else 0
	jump(delta, wall_sliding(delta))

func jump(_delta: float, on_wall: bool = false) -> void:
	if jumps > 0 and Input.is_action_just_pressed("jump"):
		velocity.y = 0
		velocity.y = lerp(up_direction.y*jump_force, 0.0, 0.2)
		jumps -=1
		if on_wall:
			velocity.x = 430*-current_direction


func wall_sliding(delta:float) -> bool:
	wall_direction.force_raycast_update()
	if is_on_floor_only(): wall_timer.start(total_wall_time)
	wall_timer.paused = true
	var can_grab: bool =  is_on_wall_only() and velocity.x !=0 and velocity.y !=0 and velocity.y > up_direction.y
	if  can_grab and wall_direction.is_colliding():
		wall_timer.paused = false
		if wall_timer.time_left > 0:
			jumps = 1
			velocity.y = abs(default_gravity-wall_timer.time_left*2)*3*delta
			return true
	return false

	
