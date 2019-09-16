extends Node

const AudioPlayer = preload("res://audio/players/standard/AudioPlayer.tscn")
const PositionalAudioPlayer = preload("res://audio/players/positional/PositionalAudioPlayer.tscn")

func play(sound, position=null):
	var instance = null
	
	if position == null:
		instance = AudioPlayer.instance()
		get_tree().root.add_child(instance)
		instance.play(sound)
	else:
		instance = PositionalAudioPlayer.instance()
		get_tree().root.add_child(instance)
		instance.play(sound, position)

	return instance