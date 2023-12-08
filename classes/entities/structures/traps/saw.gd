extends Interactable

class_name Saw

@export var chain_texture: Texture2D
@export var animation: AnimationHandler

func _ready() -> void:
	animation.set_animation("on", func() -> bool: return active, 0, func() -> float: return 1) 
	animation.set_animation("off", func() -> bool: return !active, 0, func() -> float: return 1) 
	connect("state_changed", update_animation)
	animation.update_animation()

func update_animation(_ignores : bool = false) -> void:
	animation.update_animation()
