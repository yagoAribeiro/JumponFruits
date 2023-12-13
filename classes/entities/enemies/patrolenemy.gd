extends Entity

class_name PatrolEnemy

func change_direction() -> void:
	current_state = State.Moving
	current_direction = -current_direction
	global_position.x += current_direction