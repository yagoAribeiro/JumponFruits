extends CharacterBody2D
class_name Entity

@export var life_points: int
@export var speed: float
@export var weight: float = 1.0
@export var animation: AnimationHandler
@export var collision: CollisionShape2D
@export var has_gravity: bool = true
@export var sprite: Sprite2D

const State = {
	Dead = 0,
	Moving = 1,
	Idle = 2,
	Falling = 3,
	Free = 4,
}

const LookDirection = {
	Left = -1,
	Right = 1
}

@onready var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 0) as float
var can_die: bool = false
var current_state: int = State.Idle
var current_direction: int = LookDirection.Left

func _ready():
	init_animations()

func _process(delta):
	disposer()
	apply_gravity(delta)
	move_behavior(delta)
	action_behavior(delta)
	move_and_slide()

func disposer() -> void:
	if can_die && current_state!=State.Dead:
		dies() 
		return

func init_animations() -> void:
	pass

func apply_gravity(delta: float) -> void:
	if has_gravity:
		velocity.y += delta*default_gravity*weight

func move_behavior(_delta: float) -> void:
	current_direction = LookDirection.Left if velocity.x < 0 else LookDirection.Right if velocity.x > 0 else current_direction
	sprite.flip_h = current_direction == LookDirection.Left
	if is_on_floor_only():
		current_state = State.Moving if velocity.x !=0 else State.Idle
	elif velocity.y > up_direction.y && has_gravity:
		current_state = State.Falling
	else:
		current_state = State.Free
	

func action_behavior(_delta: float) -> void:
	pass

func dies() -> void:
	current_state = State.Dead
	collision.disabled = true
	set_physics_process(false)
