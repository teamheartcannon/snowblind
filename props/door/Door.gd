extends Area2D

class_name Door

export(String) var target_map = "default"
export(Vector2) var target_location = Vector2.ZERO
export(bool) var closed = false
export(bool) var locked = false
var key_item = null

func _ready():
	connect("body_entered", self, "_on_Area2D_body_entered")

func _on_Area2D_body_entered(body):
	if not closed or locked:
		if body is Player:
			SceneChanger.change_map(target_map)
			body.set_position(target_location)
			
			# Stop the map from loading more than once
			closed = true