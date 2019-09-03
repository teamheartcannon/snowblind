extends Button

var item = "example"
var quantity = 1
var inventory = null

func _ready():
	assert(inventory != null)
	
	connect("button_down", self, "_on_ExamineCommand_button_down")

func _on_ExamineCommand_button_down():
	execute()

func execute():
	inventory.item_examine_panel.visible = true
	
	if Global.database["items"][item].has("name"):
		inventory.item_examine_panel.item_name_label.text = Global.database["items"][item]["name"]
	
	if Global.database["items"][item].has("description"):
		inventory.item_examine_panel.item_description_label.text = Global.database["items"][item]["description"]