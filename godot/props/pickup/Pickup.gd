extends StaticBody2D

class_name Pickup

const Player = preload("res://characters/player/Player.gd")

onready var sprite : Sprite = $Sprite

export(String) var item = "example"
export(int) var quantity = 1

signal picked_up

func _ready():
	connect("picked_up", self, "_on_Pickup_picked_up")
	
	if Global.database["items"][item].has("sprite"):
		sprite.texture = load(Global.database["items"][item]["sprite"])

func _on_Pickup_picked_up():
	queue_free()

func interact(entity):
	emit_signal("picked_up")
	
	if entity is Player:
		entity.inventory.insert_item(item, quantity)