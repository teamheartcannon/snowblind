extends Node2D

var player : AudioStreamPlayer

func _ready():
	player = $AudioStreamPlayer
	
	connect("tree_exited", self, "_on_AudioPlayer_tree_exit")

func play(sound):
	if sound is Array:
		player.stream = load(sound[int(rand_range(0, sound.size()))])
	elif sound is String:
		player.stream = load(sound)
	
	player.play()
	
	player.connect("finished", self, "_on_player_finished")

func _on_AudioPlayer_tree_exit():
	player.stop()

func _on_player_finished():
	queue_free()