extends Node

# Object types
const Door = preload("res://props/door/Door.tscn")

func post_import(scene):
	for layer in scene.get_children():
		if layer is TileMap:
			pass
		elif layer is Node2D:
			for object in layer.get_children():
				var type = object.get_meta("type")
				var instance = null
				
				# Change the type of node that will be spawned in based on the Type property in Tiled
				match(type):
					"door":
						instance = Door.instance()
						instance.set_position(object.get_position())
						
						if object.has_meta("width") and object.has_meta("height"):
							# Offset the position of the object by its width and height
							var width = object.get_meta("width")
							var height = object.get_meta("height")
							var shape = instance.get_child(0).shape
							
							if shape is RectangleShape2D:
								shape.extents = Vector2(width, height) / 2.0
							
							instance.set_position(instance.get_position() + (Vector2(width, height) / 2.0))
						
						if object.has_meta("map"):
							instance.target_map = object.get_meta("map")
				
				if instance != null:
					scene.add_child(instance)
					instance.set_owner(scene)
			
			layer.free()
	
	return scene