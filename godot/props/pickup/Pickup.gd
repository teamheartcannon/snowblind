extends StaticBody2D

class_name Pickup

const Player = preload("res://characters/player/Player.gd")

export(String) var item = "example"
export(int) var quantity = 1

signal picked_up

func interact(entity):
	emit_signal("picked_up")
	
	if entity is Player:
		entity.inventory.insert_item(item, quantity)
		
		queue_free()