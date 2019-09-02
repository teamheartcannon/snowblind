extends KinematicBody2D

class_name Player

onready var debug = $DebugLayer/DebugOverlay
onready var debug_display_label_position = $DebugLayer/DebugOverlay/HBoxContainer/VBoxContainer/PositionDisplay/Label2
onready var debug_display_label_velocity = $DebugLayer/DebugOverlay/HBoxContainer/VBoxContainer/VelocityDisplay/Label2
onready var debug_display_label_direction = $DebugLayer/DebugOverlay/HBoxContainer/VBoxContainer/DirectionDisplay/Label2
onready var debug_display_label_state = $DebugLayer/DebugOverlay/HBoxContainer/VBoxContainer/StateDisplay/Label2

export var move_start_time = 0.1 # In seconds
export var move_stop_time = 0.2 # In seconds
export var move_speed = 16.0 # In pixels-per-second
onready var move_acceleration = move_speed / move_start_time
onready var move_friction = move_speed / move_stop_time
var move_velocity : Vector2

enum State {
	Normal
}
var state = State.Normal

func _ready():
	assert(move_start_time > 0.0)
	assert(move_stop_time > 0.0)
	assert(move_speed > 0.0)

func _process(delta):
	match(state):
		State.Normal:
			handle_movement(delta)
	
	if debug.visible:
		#debug_display_label_direction.text = str(move_direction)
		debug_display_label_position.text = str(position)
		debug_display_label_velocity.text = str(move_velocity)
		debug_display_label_state.text = str(state)

func handle_movement(delta):
	# Horizontal
	if Input.is_action_pressed("move_left"):
		move_velocity.x = Helpers.approach(move_velocity.x, -move_speed, move_acceleration * delta)
	elif Input.is_action_pressed("move_right"):
		move_velocity.x = Helpers.approach(move_velocity.x, move_speed, move_acceleration * delta)
	else:
		move_velocity.x = Helpers.approach(move_velocity.x, 0.0, move_friction * delta)
	
	# Vertical
	if Input.is_action_pressed("move_up"):
		move_velocity.y = Helpers.approach(move_velocity.y, -move_speed, move_acceleration * delta)
	elif Input.is_action_pressed("move_down"):
		move_velocity.y = Helpers.approach(move_velocity.y, move_speed, move_acceleration * delta)
	else:
		move_velocity.y = Helpers.approach(move_velocity.y, 0.0, move_friction * delta)
	
	# Apply the forces to the player
	move_and_slide(move_velocity)