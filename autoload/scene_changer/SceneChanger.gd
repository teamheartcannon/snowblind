extends Node

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var map_root = get_tree().root.get_node("/root/Game/Maps")
onready var maps = Helpers.get_file_as_json("res://data/maps.json")

onready var map_current = map_root.get_child(0)

func _ready():
	print(map_current)

func change_map(key, delay=0.0):
	assert(maps.has(key))
	assert(delay >= 0.0)
	
	if delay > 0.0:
		yield(get_tree().create_timer(delay).start, "timeout")
	
	save_map(key)
	call_deferred("_deferred_map_change", maps[key])

func save_map(key):
	var file = File.new()
	var file_path = "user://maps.json"
	file.open(file_path, File.WRITE)
	
	var nodes = [ map_current ]
	var save_data = []
	
	while not nodes.empty():
		var node = nodes.pop_front()
		nodes += node.get_children()
	
	print(to_json(save_data))
	
	file.close()

func _deferred_map_change(path):
	if map_root.get_children().size() > 0:
		for child in map_root.get_children():
			child.queue_free()
	
	# Instantiate the new map
	var map = load(path)
	var instance = map.instance()
	map_root.add_child(instance)
	map_current = instance