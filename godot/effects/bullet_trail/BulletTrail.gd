extends Line2D

export var decay_time = 1.0
onready var decay_speed = 1.0 / decay_time

func _process(delta):
	default_color.a = Helpers.approach(default_color.a, 0.0, decay_speed * delta)
	
	if default_color.a == 0.0:
		queue_free()