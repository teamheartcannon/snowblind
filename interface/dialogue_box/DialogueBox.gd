extends CanvasLayer

export var scroll_speed = 0.1

onready var label_message : Label = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Label
onready var button_advance : Button = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Button
var display_list = []
var cursor_position = 0

func _ready():
	get_tree().paused = true
	button_advance.connect("button_down", self, "_on_Button_down")
	scroll_text()

func _process(delta):
	label_message.text = display_list[0].substr(0, cursor_position)
	
	if Input.is_action_just_pressed("ui_accept"):
		if display_list.size() - 1 > 0:
			advance_text()
		else:
			dismiss()

func advance_text():
	display_list.pop_front()
	cursor_position = display_list[0].length()
	scroll_text()

func scroll_text():
	cursor_position += 1
	yield(get_tree().create_timer(scroll_speed), "timeout")
	
	if cursor_position < display_list[0].length():
		scroll_text()

func dismiss():
	get_tree().paused = false
	queue_free()

func _on_Button_down():
	if display_list.size() - 1 > 0:
		advance_text()
	else:
		dismiss()