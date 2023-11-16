extends Interactable

class_name Controller

func _ready():
	connect("state_changed", apply_children)
	emit_signal("state_changed", active)
	
func apply_children(status: bool) -> void:
	for child in get_children():
		if status:
			(child as Interactable).toggle_on()
		else:
			(child as Interactable).toggle_off()
