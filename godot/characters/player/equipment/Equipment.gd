extends Node2D

var item = null
var metadata = null

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")

var direction : Vector2 = Vector2.DOWN

func use():
	assert(item != null)
	assert(metadata != null)
	
	var instance : Line2D = bullet_trail.instance()
	instance.points[1] = direction * metadata["range"]
	add_child(instance)