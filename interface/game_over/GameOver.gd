extends Control

onready var button_retry = $HBoxContainer/VBoxContainer/RetryButton
onready var button_quit = $HBoxContainer/VBoxContainer/QuitButton

func _ready():
	button_retry.connect("button_down", self, "_on_button_retry_down")
	button_quit.connect("button_down", self, "_on_button_quit_down")

func _on_button_retry_down():
	get_tree().change_scene("res://Game.tscn")

func _on_button_quit_down():
	get_tree().quit()