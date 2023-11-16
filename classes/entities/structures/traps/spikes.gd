extends Interactable

class_name Spikes

@export var animation: AnimationHandler

func _ready():
	animation.set_animation("show", func(): return active, 0, func(): return 1) 
	animation.set_animation("hide", func(): return !active, 0, func(): return 1) 
	connect("state_changed", update_animation)

func _on_body_entered(body: Entity):
	body.hit()

func update_animation(_ignores : bool) -> void:
	animation.update_animation()
