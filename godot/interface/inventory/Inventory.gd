extends Control

onready var animation_player : AnimationPlayer = $AnimationPlayer

func _process(delta):
	if Input.is_action_just_pressed("ui_inventory") and not animation_player.is_playing():
		if visible:
			animation_player.play("hide")
			get_tree().paused = false
		else:
			animation_player.play("show")
			get_tree().paused = true