extends Area2D

class_name DamageBox

@export var sender: Node2D

func _ready() -> void:
	connect("area_entered", on_hitbox_detection)

func on_hitbox_detection(body: HitBox) -> void:
	body.on_hit(sender, global_position)


