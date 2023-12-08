extends CharacterBody2D
class_name Entity

@export var life_points: int
@export var speed: float
@export var weight: float = 1.0
@export var animation: AnimationHandler
@export var collision: CollisionShape2D
@export var has_gravity: bool = true
@export var sprite: Sprite2D
@export var damage_box: DamageBox
@export var hit_box: HitBox

const State = {
	Dead = 0,
	Moving = 1,
	Idle = 2,
	Falling = 3,
	Hitted = 4
}

const LookDirection = {
	Left = -1,
	Right = 1
}

@onready var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 0) as float
var current_state: int = State.Idle
var current_direction: int = LookDirection.Left
var ragdoll: Ragdoll2D

func _ready() -> void:
	init_animations()

func _process(delta: float) -> void:
	apply_gravity(delta)
	if current_state != State.Dead:
		state_behavior()
		if current_state != State.Hitted:
			move_behavior(delta)
			action_behavior(delta)
		move_and_slide()
	animation.update_animation()

func init_animations() -> void:
	pass

func apply_gravity(delta: float) -> void:
	if has_gravity:
		velocity.y += delta*default_gravity*weight

func state_behavior() -> void:
	damage_box.set_deferred("monitoring", true)
	hit_box.set_deferred("monitorable", true)
	match(current_state):
		State.Idle: on_idle()
		State.Moving: on_moving()
		State.Falling: on_falling()
		State.Dead: on_dead()
		State.Hitted: on_hitted()

func move_behavior(_delta: float) -> void:
	pass
	
func action_behavior(_delta: float) -> void:
	pass

func hit(sender: Node2D, offset: Vector2) -> void:
	if current_state != State.Hitted:
		life_points -= 1
		current_state = State.Hitted
		if life_points <= 0:
			dies(sender, offset)
	

func dies(_sender: Node2D = null, _offset: Vector2 = Vector2.ZERO) -> void:
	if current_state != State.Dead:
		current_state = State.Dead
		damage_box.set_deferred("monitoring", false)
		hit_box.set_deferred("monitorable", false)

func spawn_ragdoll(offset: Vector2) -> void:
	has_gravity = false
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var impulse: Vector2 = Vector2(rng.randf_range(-150, 150), -250)
	if offset != null:
		impulse = -global_position.direction_to(offset)*250
	ragdoll = Ragdoll2D.new(collision, sprite, 5, 450, impulse)
	ragdoll.gravity_scale = 0.7
	ragdoll.global_position = global_position
	get_parent().call_deferred("add_child",ragdoll)
	visible = false

func on_idle() -> void:
	pass

func on_moving() -> void:
	pass

func on_dead() -> void:
	collision.set_deferred("disabled", true)
	has_gravity = false
	damage_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
	set_physics_process(false)

func on_falling() -> void:
	pass

func on_hitted() -> void:
	damage_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
