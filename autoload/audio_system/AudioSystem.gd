extends Node

const AudioPlayer = preload("res://audio/player/AudioPlayer.tscn")

func play(sound):
	var instance = AudioPlayer.instance()
	
	get_tree().root.add_child(instance)
	instance.play(sound)

	return instance