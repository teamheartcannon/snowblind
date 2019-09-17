extends Area2D

onready var sprite = $Sprite

func _ready():
	rotation_degrees = rand_range(0.0, 360.0)