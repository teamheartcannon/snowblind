extends Node

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var map_root = get_tree().root.get_node("/root/Game/Maps")
onready var maps = Helpers.get_file_as_json("res://data/maps.json")

onready var map_current = map_root.get_child(0)

func change_map(key, delay=0.0):
	assert(maps.has(key))
	assert(delay >= 0.0)
	
	if delay > 0.0:
		yield(get_tree().create_timer(delay).start, "timeout")
	
	# Save the current map
	save_map(get_key_from_filename(map_current.get_filename()))
	
	# Change the map over to the new one
	call_deferred("_deferred_map_change", maps[key])

	# Attempt to load the next one
	if File.new().file_exists("user://" + key + ".json"):
		call_deferred("load_map", key)

func save_map(key):
	var save_file : File = File.new()
	var file_path = "user://" + key + ".json"
	save_file.open(file_path, File.WRITE)
	
	var save_data = []
	
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("save"):
			save_data.push_back(node.save())
	
	save_file.store_string(to_json(save_data))
	save_file.close()

func load_map(key):
	var save_data = Helpers.get_file_as_json("user://" + key + ".json")
	
	for node in get_tree().get_nodes_in_group("persist"):
		node.queue_free()
	
	for object in save_data:
		var instance = load(object["filename"]).instance()
		
		if object.has("position"):
			instance.set_position(Vector2(object["position"]["x"], object["position"]["y"]))
			print(instance.get_position())
		
		if instance is Pickup:
			instance.item = object["item"]
			instance.quantity = object["quantity"]
		
		get_tree().root.add_child(instance)

func get_key_from_filename(filename):
	for key in maps.keys():
		var map = maps[key]
		
		if map == filename:
			return key

func _deferred_map_change(path):
	if map_root.get_children().size() > 0:
		for child in map_root.get_children():
			child.queue_free()
	
	var map = load(path)
	var instance = map.instance()
	map_root.add_child(instance)
	map_current = instance