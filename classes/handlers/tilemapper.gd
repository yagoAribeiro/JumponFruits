extends TileMap

class_name TileMapper

func _ready():
	map()

func map() -> void:
	for layer in get_layers_count():
		for tilecoords in get_used_cells(layer):
			var config = get_cell_tile_data(layer, tilecoords).get_custom_data("sceneconfig")
			if config == null : continue
			if config is TileSceneResource:
				var instance = (config as TileSceneResource).scene.instantiate()
				if instance is Node2D:
					(instance as Node2D).rotation_degrees = (config as TileSceneResource).rotation
					(instance as Node2D).global_position = map_to_local(tilecoords)
					erase_cell(layer, tilecoords)
					instantiate_in_group(layer, instance)


func instantiate_in_group(group: int, instance: Node) -> void:
	var node_group: Node = null
	if get_child_count()>= group+1:
		node_group = get_child(group)
	if node_group is Node2D && node_group!=null:
		node_group.call_deferred("add_child", instance)
	else:
		call_deferred("add_child",instance)
		
		
	
			
		

