extends Node

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var map_root = get_tree().root.get_node("/root/Game/Maps")
onready var maps = Helpers.get_file_as_json("res://data/maps.json")

onready var map_current = map_root.get_child(0)

signal map_changed

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
	
	# Tell the rest of the game that the map has fully changed
	emit_signal("map_changed")

func save_map(key):
	var save_file : File = File.new()
	var file_path = "user://" + key + ".json"
	save_file.open(file_path, File.WRITE)
	
	var save_data = []
	
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("save"):
			# Obtain the specific save data for this node
			var node_data = node.save()
			
			# Ensure that more general information is always present
			node_data["filename"] = node.get_filename()
			node_data["parent"] = node.get_parent().get_path()
			node_data["global_position"] = {
				"x": node.get_global_position().x,
				"y": node.get_global_position().y
			}
			
			save_data.push_back(node_data)
		else:
			printerr("No save method found for " + node.name)
	
	save_file.store_string(to_json(save_data))
	save_file.close()

func load_map(key):
	var save_data = Helpers.get_file_as_json("user://" + key + ".json")
	
	for node in get_tree().get_nodes_in_group("persist"):
		node.queue_free()
	
	for data_item in save_data:
		var instance = load(data_item["filename"]).instance()
		
		if data_item.has("global_position"):
			instance.set_global_position(
				Vector2(data_item["global_position"]["x"], data_item["global_position"]["y"])
			)
		
		if instance is Pickup:
			instance.item = data_item["item"]
			instance.quantity = data_item["quantity"]
		
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