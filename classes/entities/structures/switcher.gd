extends Interactable

class_name Switcher

@export var first: Interactable
@export var second: Interactable

func _ready() -> void:
	connect("state_changed", switch)
	emit_signal("state_changed", active)

func switch(status: bool) -> void:
	if !status:
		first.toggle_on()
		second.toggle_off()
	else:
		first.toggle_off()
		second.toggle_on()


