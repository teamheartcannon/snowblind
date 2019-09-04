extends Button

var item = "example" # The key of the item in the global items database
var quantity = 1

var inventory = null

func _ready():
	assert(inventory != null)
	
	connect("button_down", self, "_on_Button_down")

func _on_CancelButton_down():
	inventory.item_command_panel.visible = false
	inventory.item_preview_icon.texture = null
	inventory.item_preview_quantity.text = ""
	
	for listing in inventory.inventory_contents_box.get_children():
		if listing.item == item:
			listing.grab_focus()

func _on_Button_down():
	if not inventory.item_command_panel.visible:
		inventory.item_command_panel.visible = true
	
	if inventory.item_commands_box.get_child_count() > 0:
		for command in inventory.item_commands_box.get_children():
			command.queue_free()
	
	# Add the option to cancel the command
	var button_cancel = Button.new()
	button_cancel.text = "Cancel"
	button_cancel.align = ALIGN_LEFT
	button_cancel.connect("button_down", self, "_on_CancelButton_down")
	inventory.item_commands_box.add_child(button_cancel)
	button_cancel.grab_focus()
	
	if Global.database["items"][item].has("commands"):
		for command in Global.database["items"][item]["commands"]:
			var command_listing = load(command).instance()
			
			assert(command_listing != null)
			
			command_listing.inventory = inventory
			command_listing.item = item
			command_listing.quantity = quantity
			inventory.item_commands_box.add_child(command_listing)
	
	if Global.database["items"][item].has("images"):
		if Global.database["items"][item]["images"].has("icon"):
			inventory.item_preview_icon.texture = load(Global.database["items"][item]["images"]["icon"])
	
	if quantity > 1:
		inventory.item_preview_quantity.text = str(quantity)