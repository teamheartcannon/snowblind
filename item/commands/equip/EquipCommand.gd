extends "res://item/commands/ItemCommand.gd"

func _ready():
	connect("button_down", self, "_on_EquipCommand_button_down")

func _on_EquipCommand_button_down():
	execute()

func execute():
	inventory.player.equip(item)