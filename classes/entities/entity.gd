extends CharacterBody2D
class_name Entity

@export var life_points: int
@export var speed: float
@export var weight: float = 1.0
@export var animation: AnimationPlayer
@export var collision: CollisionShape2D
const State = {
	Dead = 0,
	Moving = 1,
	Idle = 2
}

const LookDirection = {
	Left = -1,
	Right = 1
}

@onready var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 0) as float

var can_die: bool = false
var current_state: int = State.Idle
var current_direction: int = LookDirection.Left

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

func apply_gravity(delta: float) -> void:
	velocity.y += delta*default_gravity*weight

func move_behavior(_delta: float) -> void:
	current_direction = LookDirection.Left if velocity.x < 0 else LookDirection.Right if velocity.x > 0 else current_direction

func action_behavior(_delta: float) -> void:
	pass

func dies() -> void:
	current_state = State.Dead
	collision.disabled = true
	set_physics_process(false)