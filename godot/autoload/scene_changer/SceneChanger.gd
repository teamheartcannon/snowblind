extends Node

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var map_root = get_tree().root.get_node("/root/Game/MapRoot")

func change_map(path, transition=null, delay=0.0):
	assert(delay >= 0.0)
	
	if delay > 0.0:
		yield(get_tree().create_timer(delay).start, "timeout")
	
	call_deferred("_deferred_map_change", path)

func _deferred_map_change(path):
	if map_root.get_children().size() > 0:
		for child in map_root.get_children():
			child.queue_free()
	
	# Instantiate the new map
	var map = load(path)
	var instance = map.instance()
	map_root.add_child(instance)