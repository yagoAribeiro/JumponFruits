extends CharacterBody2D
class_name Entity

@export var life_points: int
@export var speed: float
@export var weight: float = 1.0

const State = {
	Dead = 0,
	Moving = 1,
	Idle = 2
}

@onready var animation: AnimationPlayer = get_node("animation")
@onready var collision: CollisionShape2D = get_node("collision")
@onready var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 0) as float

var can_die: bool = false
var current_state: int = State.Idle

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
	pass

func action_behavior(_delta: float) -> void:
	pass

func dies() -> void:
	current_state = State.Dead
	collision.disabled = true
	set_physics_process(false)