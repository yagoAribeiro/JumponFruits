extends TileMap

class_name TileMapper

const GROUP_NAME: String = "group_"

func _ready():
	map()

func map() -> void:
	for layer in get_layers_count():
		for tilecoords in get_used_cells(layer):
			var config = get_cell_tile_data(layer, tilecoords).get_custom_data("sceneconfig")
			if config == null : continue
			if config is TileSceneResource:
				var instance = (config as TileSceneResource).scene.instantiate()
				if instance is TileScene:
					(instance as TileScene).custom_resource = config
					(instance as TileScene).global_position = to_global(map_to_local(tilecoords))
					erase_cell(layer, tilecoords)
					instantiate_in_group(layer, instance)


func instantiate_in_group(group: int, instance: Node) -> void:
	var node_group: Node = find_child(GROUP_NAME+str(group))
	if node_group == null:
		call_deferred("add_child",instance)
	else:
		node_group.call_deferred("add_child", instance)
		
	
			
		

