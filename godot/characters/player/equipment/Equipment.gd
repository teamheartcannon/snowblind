extends Node2D

var item = null
var metadata = null

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")

func use():
	assert(item != null)