extends AnimationPlayer
class_name AnimationHandler

@onready var animation_item_res: Resource = preload("res://classes/handlers/animation/animationHandlerItem.gd")
var animations: Array
var callbacks: Array

func _process(_delta):
	var next_animation: AnimationHandlerItem = apply_animation()
	if next_animation!=null:
		play(next_animation.name, -1, next_animation.speed_factor.call())

func set_animation(animation_name: StringName, animation_condition: Callable, priority: int, speed_factor: Callable, callback: Callable = func():) -> void:
	animations.append(animation_item_res.new(animation_name, animation_condition, priority, speed_factor))
	animations.sort_custom(func(x, y): return (x as AnimationHandlerItem).animation_priority <= (y as AnimationHandlerItem).animation_priority)
	callbacks.append({"name": animation_name, "callback": callback})
	callbacks.sort_custom(func(x, y): return (x as Dictionary)["name"] <= (y as Dictionary)["name"])
func apply_animation() -> AnimationHandlerItem:
	for animation in animations:
		var animation_item: AnimationHandlerItem = animation as AnimationHandlerItem
		if animation_item.animation_condition.call():
			return animation_item
	return null

func _on_animation_finished(anim_name:StringName):
	var index: int = callbacks.bsearch_custom(anim_name, func(element, search): return (element as Dictionary)["name"] < search)
	((callbacks[index] as Dictionary)["callback"] as Callable).call()