extends Area2D

class_name Pickup

export(String) var item = "example"
export(int) var quantity = 1

signal picked_up

func ready():
	connect("picked_up", self, "_on_Pickup_picked_up")

func interact():
	emit_signal("picked_up")

func _on_Pickup_picked_up():
	queue_free()