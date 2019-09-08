extends Node2D

export(String) var item = null
onready var metadata = Global.database["items"][item]

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")

var drawn = false

func _process(delta):
	if metadata is Dictionary:
		if drawn:
			match(metadata["transmission"]):
				"semi_automatic":
					if Input.is_action_just_pressed("combat_attack"):
						use()
				"automatic":
					if Input.is_action_pressed("combat_aim"):
						pass

func use():
	assert(item != null)
	assert(metadata != null)
	
	var angle = position.angle()
	angle += deg2rad(rand_range(-metadata["accuracy"], metadata["accuracy"]))
	
	# Create a trail for this shot
	var instance : Line2D = bullet_trail.instance()
	instance.points[1] = Vector2(cos(angle), sin(angle)) * metadata["range"]
	add_child(instance)