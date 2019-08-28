extends Node

# Object types
const Door = preload("res://doors/Door.tscn")

func post_import(scene):
	for layer in scene.get_children():
		if layer is TileMap:
			pass
		elif layer is Node2D:
			for object in layer.get_children():
				if object.has_meta("type"):
					var type = object.get_meta("type")
					var node_to_clone = null
					
					# Change the type of node that will be spawned in based on the Type property in Tiled
					match(type):
						"door":
							node_to_clone = Door
					
					if node_to_clone is PackedScene:
						var instance = node_to_clone.instance()
						instance.set_position(object.get_position())
						
						match(type):
							"door":
								if object.has_meta("map"):
									instance.target_map = object.get_meta("map")
						
						scene.add_child(instance)
						instance.set_owner(scene)
			
			layer.queue_free()
	
	return scene