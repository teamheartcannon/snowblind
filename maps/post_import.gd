extends Node

# Object types
const Door = preload("res://props/door/Door.tscn")
const Pickup = preload("res://props/pickup/Pickup.tscn")

func post_import(scene):
	# Stores the size of the largest tilemap
	var size_largest : Vector2 = Vector2.ZERO
	
	for layer in scene.get_children():
		if layer is TileMap:
			var tilemap : TileMap = layer as TileMap
			#var size : Vector2 = Helpers.get_tilemap_size(tilemap)
			var cell_bounds = tilemap.get_used_rect()
			var cell_to_pixel = Transform2D(
				Vector2(
					tilemap.cell_size.x * tilemap.scale.x,
					0
				),
				Vector2(
					0,
					tilemap.cell_size.y * tilemap.scale.y
				),
				Vector2.ZERO
			)
			var used_rect = Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)
			
			if used_rect.size > size_largest:
				size_largest = used_rect.size
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
					
					"pickup":
						instance = Pickup.instance()
						instance.set_position(object.get_position())
						
						if object.has_meta("item"):
							instance.item = object.get_meta("item")
						
						if object.has_meta("quantity"):
							instance.quantity = object.get_meta("quantity")
				
				if instance != null:
					scene.add_child(instance)
					instance.set_owner(scene)
			
			layer.free()
	
	scene.set_meta("size", size_largest)
	
	return scene