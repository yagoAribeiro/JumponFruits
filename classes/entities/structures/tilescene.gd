extends Node2D

class_name TileScene

@export var custom_resource: TileSceneResource : 
	set(value):
		if value!=null:
			custom_resource = value
			apply_custom_resource(value)

func apply_custom_resource(resource: TileSceneResource) -> void:
	rotation_degrees = resource.rotation
