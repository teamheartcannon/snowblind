extends Node

onready var database : Dictionary = {
	"items": Helpers.get_file_as_json("res://data/items.json")
}
var save_slot : int = -1