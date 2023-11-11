extends Area2D

class_name HitBox

@export var receiver: Entity

func hit() -> void:
	receiver.hit(global_position)



