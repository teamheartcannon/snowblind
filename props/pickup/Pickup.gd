extends StaticBody2D

class_name Pickup

const Player = preload("res://characters/player/Player.gd")
const DialogueBox = preload("res://interface/dialogue_box/DialogueBox.tscn")

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
	var instance = DialogueBox.instance()
	
	# Change the plurality of the pickup message based on the quantity
	if quantity == 1:
		instance.display_list.push_back("Picked up a " + Global.database["items"][item]["name"] + ".")
	else:
		instance.display_list.push_back("I got " + str(quantity) + " " + Global.database["items"][item]["name"] + "s.")
	
	get_tree().root.add_child(instance)
	
	emit_signal("picked_up")
	
	if entity is Player:
		entity.inventory.insert_item(item, quantity)

func save():
	var save_data = {
		"item": item,
		"quantity": quantity
	}
	
	return save_data