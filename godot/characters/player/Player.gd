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
var direction : Vector2 = Vector2.DOWN

export var reach = 4.0

onready var inventory = $InventoryLayer/Inventory

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
			handle_direction()
			handle_interaction()
	
	if Input.is_action_just_pressed("ui_debug"):
		debug.visible = not debug.visible
	
	if debug.visible:
		debug_display_label_direction.text = str(direction)
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

func handle_direction():
	var input_direction = Vector2.ZERO
	
	# Horizontal
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		input_direction.x += 1
	
	# Vertical
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	elif Input.is_action_pressed("move_down"):
		input_direction.y += 1
	
	if input_direction != Vector2.ZERO:
		direction = input_direction

func handle_interaction():
	if Input.is_action_just_pressed("interact"):
		var direct_space_state : Physics2DDirectSpaceState = get_world_2d().direct_space_state
		var result = direct_space_state.intersect_ray(
			position, # From
			position + (direction * reach), # To
			[ self ] # Collision exceptions
		)
		
		if result.size() > 0:
			var target = result["collider"]
			
			if target.has_method("interact"):
				target.interact(self)