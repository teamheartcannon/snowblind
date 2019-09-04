extends KinematicBody2D

class_name Player

onready var debug_overlay = $DebugLayer/DebugOverlay
onready var debug_display_label_position = debug_overlay.get_node("HBoxContainer/VBoxContainer/PositionDisplay/Label2")
onready var debug_display_label_velocity = debug_overlay.get_node("HBoxContainer/VBoxContainer/VelocityDisplay/Label2")
onready var debug_display_label_direction = debug_overlay.get_node("HBoxContainer/VBoxContainer/DirectionDisplay/Label2")
onready var debug_display_label_state = debug_overlay.get_node("HBoxContainer/VBoxContainer/StateDisplay/Label2")

export var move_start_time = 0.1 # In seconds
export var move_stop_time = 0.2 # In seconds
export(Dictionary) var move_speeds = {
	State.Normal: 16.0,
	State.Aiming: 8.0
}
var move_speed = move_speeds[State.Normal] # In pixels-per-second
onready var move_acceleration = move_speed / move_start_time
onready var move_friction = move_speed / move_stop_time
var move_velocity : Vector2
var direction : Vector2 = Vector2.DOWN

export var pickup_reach = 4.0

onready var inventory = $InventoryLayer/Inventory
onready var equipment = $Equipment

enum State {
	Normal,
	Aiming,
	Reloading
}
var state = State.Normal

signal equipment_changed

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
			
			if equipment.item != null:
				if Input.is_action_pressed("combat_aim"):
					transition(State.Aiming)
		State.Aiming:
			handle_movement(delta)
			
			if not Input.is_action_pressed("combat_aim"):
				transition(State.Normal)
			
			if Input.is_action_just_pressed("combat_attack"):
				equipment.use()
	
	handle_debugging()

func handle_debugging():
	if Input.is_action_just_pressed("ui_debug"):
		debug_overlay.visible = not debug_overlay.visible
	
	if debug_overlay.visible:
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
			position + (direction * pickup_reach), # To
			[ self ] # Collision exceptions
		)
		
		if result.size() > 0:
			var target = result["collider"]
			
			if target.has_method("interact"):
				target.interact(self)

func handle_attacking():
	pass

func transition(new_state):
	if move_speeds.has(new_state):
		move_speed = move_speeds[new_state]
	
	match(new_state):
		State.Aiming:
			equipment.direction = direction
			equipment.position = (direction * pickup_reach)
	
	state = new_state

func equip(item):
	assert(Global.database["items"].has(item))
	assert(Global.database["items"][item].has("commands"))
	assert(Global.database["items"][item]["commands"].has("res://item/commands/equip/EquipCommand.tscn"))
	
	equipment.metadata = Global.database["items"][item]
	equipment.item = item
	
	# Let the rest of the game know which item the player equipped
	emit_signal("equipment_changed", item)