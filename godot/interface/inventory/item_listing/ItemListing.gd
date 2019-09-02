extends Button

onready var items = Helpers.get_file_as_json("res://data/items.json")
var item = "example"

onready var item_preview : TextureRect = get_node("../../../../../VBoxContainer/ItemPreview")
onready var item_command_panel : Panel = get_node("../../../../CommandPanel")

func _ready():
	connect("button_down", self, "_on_Button_down")

func _on_Button_down():
	if not item_command_panel.visible:
		item_command_panel.visible = true
	
		if items[item].has("icon"):
			item_preview.texture = load(items[item]["icon"])