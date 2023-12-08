extends Area2D

class_name HitBox

@export var receiver: Entity

func on_hit(sender: Node2D, offset: Vector2) -> void:
	receiver.hit(sender, offset)



