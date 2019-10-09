extends Control

const ItemListing = preload("res://interface/inventory/item_listing/ItemListing.tscn")

var player = null

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var inventory_contents_box : VBoxContainer = $MainScreen/VBoxContainer/HBoxContainer/RightContainer/ItemPanel/ScrollContainer/VBoxContainer
onready var item_examine_panel = $ExaminePanel
onready var item_preview_icon : TextureRect = $MainScreen/VBoxContainer/HBoxContainer/LeftContainer/ItemPreview/Icon
onready var item_preview_quantity : Label = $MainScreen/VBoxContainer/HBoxContainer/LeftContainer/ItemPreview/Quantity
onready var item_command_panel : PanelContainer = $MainScreen/VBoxContainer/HBoxContainer/RightContainer/CommandPanel
onready var item_commands_box : VBoxContainer = $MainScreen/VBoxContainer/HBoxContainer/RightContainer/CommandPanel/ScrollContainer/VBoxContainer
onready var player_equipment_display : TextureRect = $MainScreen/VBoxContainer/HBoxContainer/LeftContainer/EquipmentDisplay
onready var player_health_display = $MainScreen/VBoxContainer/HBoxContainer/LeftContainer/HealthDisplay

var items = Helpers.get_file_as_json("res://data/items.json")
export(Dictionary) var contents = {}

const SOUND_ZIP = [
	"res://interface/inventory/Zip1.wav",
	"res://interface/inventory/Zip2.wav"
]
const SOUND_UNZIP = [
	"res://interface/inventory/UnZip1.wav",
	"res://interface/inventory/UnZip2.wav"
]

signal contents_changed

func _ready():
	call_deferred("setup_inventory")

func _process(delta):
	# Allow the inventory to be opened and closed
	if Input.is_action_just_pressed("ui_inventory") and not animation_player.is_playing():
		if visible:
			hide()
			AudioSystem.play(SOUND_ZIP)
		else:
			show()
			AudioSystem.play(SOUND_UNZIP)
			
			if inventory_contents_box.get_child_count() > 0:
				var listing = inventory_contents_box.get_child(0)
				listing.grab_focus()
				listing.grab_click_focus()

func _on_Inventory_contents_changed():
	update_item_list()

func _on_Player_equipment_changed(item):
	if Global.database["items"][item].has("images"):
		if Global.database["items"][item]["images"].has("icon"):
			player_equipment_display.texture = load(Global.database["items"][item]["images"]["icon"])

func _on_Player_health_changed(amount):
	var background : TextureRect = player_health_display.get_node("Background")
	var shader = background.material as ShaderMaterial
	var x = amount / 100.0
	
	shader.set_shader_param("x", x)

func setup_inventory():
	if inventory_contents_box.get_child_count() > 0:
		inventory_contents_box.get_child(0).grab_focus()
	
	connect("contents_changed", self, "_on_Inventory_contents_changed")
	player.connect("equipment_changed", self, "_on_Player_equipment_changed")
	player.connect("health_changed", self, "_on_Player_health_changed")
	
	update_item_list()

func show():
	animation_player.play("show")
	get_tree().paused = true

func hide():
	animation_player.play("hide")
	get_tree().paused = false

func has_item(key):
	return contents.has(key)

func get_item_quantity(key):
	return contents[key] if contents.has[key] else 0

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
	if inventory_contents_box.get_child_count() > 0:
		for listing in inventory_contents_box.get_children():
			listing.queue_free()
	
	if contents.size() > 0:
		for item in contents.keys():
			var instance = ItemListing.instance()
			instance.text = items[item]["name"]
			instance.item = item
			instance.quantity = contents[item]
			instance.inventory = self
			
			inventory_contents_box.add_child(instance)
	else:
		var label = Label.new()
		label.text = "Empty"
		inventory_contents_box.add_child(label)