extends Node2D

var item = null
var metadata = null

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")

func use():
	assert(item != null)
	assert(metadata != null)
	
	var player_position = get_node("/root/Game/Player").global_position
	var angle = player_position.angle_to_point(global_position)
	
	print("angle (degrees)", rad2deg(angle))
	print("player_position: ",player_position)
	print("global_position: ", global_position)
	print("position: ", position)
	
	# Create a trail for this shot
	var instance : Line2D = bullet_trail.instance()
	instance.points[1] = Vector2(cos(angle), sin(angle)) * -metadata["range"]
	add_child(instance)