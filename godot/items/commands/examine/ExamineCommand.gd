extends Button

onready var items = Helpers.get_file_as_json("res://data/items.json")
var item = "example"

func _ready():
	connect("button_down", self, "_on_ExamineCommand_button_down")

func _on_ExamineCommand_button_down():
	execute()

func execute():
	if items[item].has("description"):
		print(items[item]["description"])