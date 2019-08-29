extends Node2D

class_name Game

onready var map_root = $Maps
onready var map_current = map_root.get_child(0)

func _ready():
	var window_width = 1024
	var window_height = 768
	
	OS.window_size = Vector2(window_width, window_height)
	OS.window_position = (OS.get_screen_size() / 2.0 ) - (OS.window_size / 2.0)