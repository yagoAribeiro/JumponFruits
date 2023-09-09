extends Entity
class_name Player

@export var jump_force: float
var jumps: int = 2

func _ready():
	pass

func move_behavior(_delta:float) -> void:
	var direction:Vector2 = Vector2.ZERO
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = lerp(velocity.x, direction.x*speed, 0.25)

func action_behavior(delta:float) -> void:
	jumps = 2 if is_on_floor() else 1 if jumps > 0 else 0
	jump(delta)

func jump(_delta: float) -> void:
	if jumps > 0 and Input.is_action_just_pressed("jump"):
		velocity.y = 0
		velocity.y = lerp(up_direction.y*jump_force, 0.0, 0.2)
		jumps -=1
