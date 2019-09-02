extends Button

onready var items = Helpers.get_file_as_json("res://data/items.json")
var item = "example"

onready var item_preview : TextureRect = get_node("../../../../../VBoxContainer/ItemPreview")
onready var item_command_panel = get_node("../../../../CommandPanel")
onready var item_list : VBoxContainer = get_node("../../../../ItemPanel/ScrollContainer/VBoxContainer")

func _ready():
	connect("button_down", self, "_on_Button_down")

func _on_CancelButton_down():
	item_command_panel.visible = false
	
	for listing in item_list.get_children():
		if listing.item == item:
			listing.grab_focus()

func _on_Button_down():
	if not item_command_panel.visible:
		item_command_panel.visible = true
	
	var command_box = item_command_panel.get_node("ScrollContainer/VBoxContainer")
	
	if command_box.get_child_count() > 0:
		for command in command_box.get_children():
			command.queue_free()
	
	# Add the option to cancel the command
	var button_cancel = Button.new()
	button_cancel.text = "Cancel"
	button_cancel.align = ALIGN_LEFT
	button_cancel.connect("button_down", self, "_on_CancelButton_down")
	command_box.add_child(button_cancel)
	button_cancel.grab_focus()
	
	if items[item].has("commands"):
		for command in items[item]["commands"]:
			var command_listing = load(command).instance()
			command_box.add_child(command_listing)

	if items[item].has("icon"):
		item_preview.texture = load(items[item]["icon"])