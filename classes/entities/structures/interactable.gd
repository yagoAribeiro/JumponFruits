extends Node

class_name Interactable

@export var active : bool = false

signal state_changed(status: bool)

func toggle() -> void:
	active = !active
	state_changed.emit(active)

func toggle_on() -> void:
	if (!active):
		toggle()

func toggle_off() -> void:
	if (active):
		toggle()


	
