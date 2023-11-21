extends Interactable

class_name Spikes

@export var animation: AnimationHandler

func _ready():
	animation.set_animation("show", func(): return active, 0, func(): return 1) 
	animation.set_animation("hide", func(): return !active, 0, func(): return 1) 
	connect("state_changed", update_animation)
	animation.update_animation()

func update_animation(_ignores : bool = false) -> void:
	animation.update_animation()
