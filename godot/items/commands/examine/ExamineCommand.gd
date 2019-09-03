extends Button

var item = "example"
var inventory = null

func _ready():
	connect("button_down", self, "_on_ExamineCommand_button_down")
	print(inventory.item_examine_panel.name)

func _on_ExamineCommand_button_down():
	execute()

func execute():
	if Global.database["items"][item].has("description"):
		print(Global.database["items"][item]["description"])