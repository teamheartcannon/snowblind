extends Node2D

func _ready():
	var window_width = 1280
	var window_height = 720
	
	OS.window_size = Vector2(window_width, window_height)
	OS.window_position = (OS.get_screen_size() / 2.0 ) - (OS.window_size / 2.0)