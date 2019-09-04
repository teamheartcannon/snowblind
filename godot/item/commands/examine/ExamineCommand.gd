extends "res://item/commands/ItemCommand.gd"

func _ready():
	connect("button_down", self, "_on_ExamineCommand_button_down")

func _on_ExamineCommand_button_down():
	execute()

func execute():
	assert(Global.database["items"].has(item))
	
	inventory.item_examine_panel.visible = true
	
	if Global.database["items"][item].has("name"):
		inventory.item_examine_panel.item_name_label.text = Global.database["items"][item]["name"]
	
	if Global.database["items"][item].has("description"):
		inventory.item_examine_panel.item_description_label.text = Global.database["items"][item]["description"]
	
	if Global.database["items"][item].has("images"):
		if Global.database["items"][item]["images"].has("preview"):
			var icon : TextureRect = inventory.item_examine_panel.item_preview
			icon.texture = load(Global.database["items"][item]["images"]["preview"])