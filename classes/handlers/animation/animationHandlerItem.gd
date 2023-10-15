extends Node
class_name AnimationHandlerItem

var animation_condition: Callable
var speed_factor: Callable
var animation_priority: int

func _init(animation_name: StringName, condition: Callable, priority: int, speed_factor_call: Callable):
    self.name = animation_name
    self.animation_condition = condition
    self.animation_priority = priority
    self.speed_factor = speed_factor_call