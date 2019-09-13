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