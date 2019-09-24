extends Node

func approach(from, to, amount):
	if from < to:
		from += amount
		
		if from > to:
			return to
	else:
		from -= amount
		
		if from < to:
			return to
	
	return from

func get_file_as_json(path):
	var file = File.new()
	assert(file.file_exists(path))
	file.open(path, File.READ)
	
	var json = JSON.parse(file.get_as_text())
	assert(json.error == OK)
	
	file.close()
	
	return json.result

func get_tilemap_size(tilemap : TileMap) -> Vector2:
	assert(tilemap is TileMap)
	
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
	
	return used_rect.size