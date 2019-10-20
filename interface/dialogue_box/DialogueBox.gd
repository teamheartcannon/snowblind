extends Control

export var scroll_speed = 0.1

onready var label_speaker : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Label
onready var label_message : Label = $HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/Label
var display_text : String
var cursor_position = 0

signal text_displayed

func _ready():
	display_text = label_message.text
	
	scroll_text(scroll_speed)

func _process(delta):
	label_message.text = display_text.substr(0, cursor_position)
	
	if Input.is_action_just_pressed("ui_accept"):
		cursor_position = display_text.length()

func scroll_text(speed):
	cursor_position += 1
	yield(get_tree().create_timer(scroll_speed), "timeout")
	
	if cursor_position < display_text.length():
		scroll_text(speed)
	else:
		emit_signal("text_displayed")