extends StaticBody2D

class_name Pickup

const Player = preload("res://characters/player/Player.gd")

onready var sprite : Sprite = $Sprite

export(String) var item = null
export(int) var quantity = 1

signal picked_up

func _ready():
	connect("picked_up", self, "_on_Pickup_picked_up")
	
	if item != null:
		if Global.database["items"].has(item):
			if Global.database["items"][item].has("images"):
				if Global.database["items"][item]["images"].has("pickup"):
					sprite.texture = load(Global.database["items"][item]["images"]["pickup"])

func _on_Pickup_picked_up():
	queue_free()

func interact(entity):
	emit_signal("picked_up")
	
	if entity is Player:
		entity.inventory.insert_item(item, quantity)

func save():
	var save_data = {
		"filename": get_filename(),
		"parent": get_parent().get_path(),
		"position": {
			"x": position.x,
			"y": position.y
		},
		"item": item,
		"quantity": quantity
	}
	
	return save_data