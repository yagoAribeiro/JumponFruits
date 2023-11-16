extends Interactable

class_name Cronometer

@export var interactable: Interactable
@export var countdown: float = 3

var timer: Timer = Timer.new()


func _ready():
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", on_timeout)
	timer.start(countdown)


func toggle_on() -> void:
	super.toggle_on()
	timer.paused = false
	timer.start(countdown)


func toggle_off() -> void:
	super.toggle_off()
	timer.stop()


func on_timeout() -> void:
	interactable.toggle()
