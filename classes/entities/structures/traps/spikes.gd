extends Interactable

class_name Spikes

@export var animation: AnimationHandler

func _ready() -> void:
	animation.set_animation("show", func() -> bool: return active, 0, func() -> float: return 1) 
	animation.set_animation("hide", func() -> bool: return !active, 0, func() -> float: return 1) 
	connect("state_changed", update_animation)
	animation.update_animation()

func update_animation(_ignores : bool = false) -> void:
	animation.update_animation()
