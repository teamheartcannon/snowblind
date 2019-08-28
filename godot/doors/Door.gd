extends Area2D

class_name Door

export(String) var target_map = "default"
export(Vector2) var target_location = Vector2.ZERO
export(bool) var closed = false

const Player = preload("res://characters/player/Player.gd")

func _ready():
	connect("body_entered", self, "_on_Area2D_body_entered")

func _on_Area2D_body_entered(body):
	if body is Player:
		SceneChanger.change_map(target_map)
		body.set_position(target_location)