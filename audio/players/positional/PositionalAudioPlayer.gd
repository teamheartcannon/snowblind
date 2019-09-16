extends Node2D

onready var player : AudioStreamPlayer2D = get_child(0) as AudioStreamPlayer2D

func _ready():
	connect("tree_exited", self, "_on_AudioPlayer_tree_exit")
	print(player)

func play(sound, location):
	assert(location is Vector2)
	
	if sound is Array:
		player.stream = load(sound[int(rand_range(0, sound.size()))])
	elif sound is String:
		player.stream = load(sound)
	
	player.position = location
	player.play()
	
	player.connect("finished", self, "_on_player_finished")

func _on_AudioPlayer_tree_exit():
	player.stop()

func _on_player_finished():
	queue_free()