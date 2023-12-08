extends AnimationPlayer
class_name AnimationHandler

@onready var animation_item_res: Resource = preload("res://classes/handlers/animation/animationHandlerItem.gd")
var animations: Array
var callbacks: Array

func _ready() -> void:
	connect("animation_finished", _on_animation_finished)

func set_animation(animation_name: String, animation_condition: Callable, priority: int, speed_factor: Callable, callback: Callable = func() -> void:) -> void:
	animations.append(animation_item_res.new(animation_name, animation_condition, priority, speed_factor))
	animations.sort_custom(func(x: AnimationHandlerItem, y: AnimationHandlerItem) -> bool: return x.animation_priority <= y.animation_priority)
	callbacks.append({"name": animation_name, "callback": callback})
	callbacks.sort_custom(func(x: Dictionary, y: Dictionary) -> bool : return x.name<=y.name)

func update_animation() -> void:
	var next_animation: AnimationHandlerItem
	for animation: AnimationHandlerItem in animations:
		var animation_item: AnimationHandlerItem = animation as AnimationHandlerItem
		if animation_item.animation_condition.call():
			next_animation = animation
			break;
	if next_animation!=null:
		play(next_animation.name, -1, next_animation.speed_factor.call())

func _on_animation_finished(anim_name: String) -> void:
	var index: int = callbacks.bsearch_custom(anim_name, func(element: Dictionary, search: String) -> bool: return element["name"] < search)
	((callbacks[index] as Dictionary)["callback"] as Callable).call()
