extends "res://item/commands/ItemCommand.gd"

onready var player = get_tree().root.get_node("Game/Player")

func _ready():
	connect("button_down", self, "_on_EquipCommand_button_down")

func _on_EquipCommand_button_down():
	execute()

func execute():
	player.equip(item)