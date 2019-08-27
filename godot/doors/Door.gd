extends Area2D

export(String, FILE, "*.tscn") var target_scene = "res://Game.tscn"

const Player = preload("res://characters/player/Player.gd")

func _ready():
	connect("body_entered", self, "_on_Area2D_body_entered")

func _on_Area2D_body_entered(body):
	if body is Player:
		get_tree().change_scene(target_scene)