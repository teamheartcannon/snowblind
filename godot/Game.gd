extends Node2D

class_name Game

onready var map_root = $MapRoot
onready var map_current = $MapRoot.get_child(0)

func _ready():
	var window_width = 1280
	var window_height = 720
	
	OS.window_size = Vector2(window_width, window_height)
	OS.window_position = (OS.get_screen_size() / 2.0 ) - (OS.window_size / 2.0)