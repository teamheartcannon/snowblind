extends Control

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var item_display : VBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PanelContainer/ScrollContainer/VBoxContainer
onready var item_listing = preload("res://interface/inventory/item_listing/ItemListing.tscn")

var items = Helpers.get_file_as_json("res://data/items.json")
var contents = {}

signal contents_changed

func _ready():
	item_display.get_child(0).grab_click_focus()
	item_display.get_child(0).grab_focus()
	connect("contents_changed", self, "_on_Inventory_contents_changed")

func _process(delta):
	# Allow the inventory to be opened and closed
	if Input.is_action_just_pressed("ui_inventory") and not animation_player.is_playing():
		if visible:
			hide()
		else:
			show()

func _on_Inventory_contents_changed():
	update_item_list()

func show():
	animation_player.play("show")
	get_tree().paused = true

func hide():
	animation_player.play("hide")
	get_tree().paused = false

func insert_item(key, quantity=1):
	if contents.has(key):
		contents[key] += quantity
	else:
		contents[key] = quantity
	
	emit_signal("contents_changed")

func remove_item(key, quantity=1):
	assert(items.has(key))
	
	if contents[key] > quantity:
		contents[key] -= quantity
	else:
		contents.erase(key)
	
	emit_signal("contents_changed")

func update_item_list():
	if item_display.get_child_count() > 0:
		for listing in item_display.get_children():
			listing.queue_free()
	
	for item in contents.keys():
		var instance = item_listing.instance()
		instance.key = item
		
		item_display.add_child(instance)