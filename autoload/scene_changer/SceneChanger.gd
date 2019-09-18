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
	
	save_map(key)
	call_deferred("_deferred_map_change", maps[key])

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
	print("test")

func _deferred_map_change(path):
	if map_root.get_children().size() > 0:
		for child in map_root.get_children():
			child.queue_free()
	
	var map = load(path)
	var instance = map.instance()
	map_root.add_child(instance)
	map_current = instance