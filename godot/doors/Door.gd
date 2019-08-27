extends Area2D

export(String, FILE, "*.tmx") var target_map = "res://maps/test/test.tmx"
export(Vector2) var target_location = Vector2.ZERO

const Player = preload("res://characters/player/Player.gd")

func _ready():
	connect("body_entered", self, "_on_Area2D_body_entered")

func _on_Area2D_body_entered(body):
	if body is Player:
		SceneChanger.change_map(target_map)
		body.set_position(target_location)