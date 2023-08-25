extends Node
class_name Entity

@onready var animation: AnimationPlayer = get_node("animation")
@onready var collision: CollisionShape2D = get_node("collision")

@export var life_points: int
@export var speed: int
@export var jump_force: int
@export var weight: float = 1.0

const State = {
	Dead = 0,
	Moving = 1,
	Idle = 2
}

var current_state: int = State.Idle

func _ready():
	pass 

func _process(delta):
	if life_points <= 0:
		dies()
		return
	move_behavior(delta)
	action_behavior(delta)


func move_behavior(_delta: float) -> void:
	pass

func action_behavior(_delta: float) -> void:
	pass

func dies() -> void:
	current_state = State.Dead
	collision.disabled = true
	set_physics_process(false)