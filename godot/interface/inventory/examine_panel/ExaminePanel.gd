extends PanelContainer

export var scroll_speed = 4
onready var scroll_container : ScrollContainer = $MarginContainer/HBoxContainer/VBoxContainer/BottomContainer/PanelContainer/ScrollContainer

onready var item_name_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/BottomContainer/PanelContainer/ScrollContainer/VBoxContainer/Name
onready var item_description_label : Label = $MarginContainer/HBoxContainer/VBoxContainer/BottomContainer/PanelContainer/ScrollContainer/VBoxContainer/Description

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false
	
	if visible:
		if Input.is_action_pressed("ui_up"):
			scroll_container.scroll_vertical += scroll_speed
		elif Input.is_action_pressed("ui_down"):
			scroll_container.scroll_vertical -= scroll_speed