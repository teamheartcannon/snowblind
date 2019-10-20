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

const HEALTH_MAX = 100
var health = HEALTH_MAX
var sanity = 100

export var pickup_reach = 4.0

onready var camera = $Camera2D

onready var inventory = $InventoryLayer/Inventory
onready var equipment = $Equipment

onready var spritesheets = {
	"head": {
		Vector2(-1, -1): preload("res://characters/player/body/head/up_side.png"), # Up-left
		Vector2.UP: preload("res://characters/player/body/head/up.png"),
		Vector2(1, -1): preload("res://characters/player/body/head/up_side.png"), # Up-right
		Vector2.DOWN: preload("res://characters/player/body/head/down.png"),
		Vector2(-1, 1): preload("res://characters/player/body/head/down_side.png"), # Down-left
		Vector2.RIGHT: preload("res://characters/player/body/head/side.png"),
		Vector2(1, 1): preload("res://characters/player/body/head/down_side.png"), # Down-right
		Vector2.LEFT: preload("res://characters/player/body/head/side.png")
	},
	"torso": {
		Vector2(-1, -1): preload("res://characters/player/body/torso/torso.png"), # Up-left
		Vector2.UP: preload("res://characters/player/body/torso/torso.png"),
		Vector2(1, -1): preload("res://characters/player/body/torso/torso.png"), # Up-right
		Vector2.DOWN: preload("res://characters/player/body/torso/torso.png"),
		Vector2(-1, 1): preload("res://characters/player/body/torso/torso.png"), # Down-left
		Vector2.RIGHT: preload("res://characters/player/body/torso/torso.png"),
		Vector2(1, 1): preload("res://characters/player/body/torso/torso.png"), # Down-right
		Vector2.LEFT: preload("res://characters/player/body/torso/torso.png")
	},
	"legs": {
		Vector2(-1, -1): preload("res://characters/player/body/legs/up_side.png"), # Up-left
		Vector2.UP: preload("res://characters/player/body/legs/up.png"),
		Vector2(1, -1): preload("res://characters/player/body/legs/up_side.png"), # Up-right
		Vector2.DOWN: preload("res://characters/player/body/legs/down.png"),
		Vector2(-1, 1): preload("res://characters/player/body/legs/down_side.png"), # Down-left
		Vector2.RIGHT: preload("res://characters/player/body/legs/side.png"),
		Vector2(1, 1): preload("res://characters/player/body/legs/down_side.png"), # Down-right
		Vector2.LEFT: preload("res://characters/player/body/legs/side.png")
	}
}
onready var body_parts = {
	"head": $Body/Head/Sprite,
	"torso": $Body/Torso/Sprite,
	"legs": $Body/Legs/Sprite
}

enum State {
	Normal,
	Aiming,
	Reloading
}
var state = State.Normal

signal equipment_changed
signal health_changed
signal sanity_changed
signal death

func _ready():
	assert(move_start_time > 0.0)
	assert(move_stop_time > 0.0)
	assert(move_speed > 0.0)
	
	equipment.holder = self
	inventory.player = self
	
	limit_camera_to_current_map()
	SceneChanger.connect("map_changed", self, "_on_SceneChanger_map_changed")
	connect("death", self, "_on_Player_death")

func _process(delta):
	match(state):
		State.Normal:
			handle_movement(delta)
			handle_direction()
			handle_interaction()
			process_body_parts()
			
			if equipment.item != null:
				if Input.is_action_pressed("combat_aim"):
					transition(State.Aiming)
		State.Aiming:
			handle_movement(delta)
			
			if not Input.is_action_pressed("combat_aim"):
				transition(State.Normal)
	
	handle_debugging()

func _on_SceneChanger_map_changed():
	limit_camera_to_current_map()

func _on_Player_death():
	get_tree().change_scene("res://interface/game_over/GameOver.tscn")

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

func limit_camera_to_current_map():
	camera.limit_top = 0
	camera.limit_left = 0
	
	if SceneChanger.map_current.has_meta("size"):
		camera.limit_right = SceneChanger.map_current.get_meta("size").x
		camera.limit_bottom = SceneChanger.map_current.get_meta("size").y

func process_body_parts():
	for key in body_parts.keys():
		body_parts[key].flip_h = false if direction.x > 0 else true
	
	for key in spritesheets.keys():
		if spritesheets[key].has(direction):
			body_parts[key].texture = spritesheets[key][direction]

func transition(new_state):
	if move_speeds.has(new_state):
		move_speed = move_speeds[new_state]
	
	match(new_state):
		State.Normal:
			equipment.state = equipment.State.Holstered
		State.Aiming:
			equipment.position = direction * pickup_reach
			equipment.state = equipment.State.Drawn
	
	state = new_state

func equip(item):
	assert(Global.database["items"].has(item))
	assert(Global.database["items"][item].has("commands"))
	assert(Global.database["items"][item]["commands"].has("res://item/commands/equip/EquipCommand.tscn"))
	
	equipment.metadata = Global.database["items"][item]
	equipment.item = item
	
	# Let the rest of the game know which item the player equipped
	emit_signal("equipment_changed", item)

func heal(amount):
	health = Helpers.approach(health, HEALTH_MAX, amount)
	
	emit_signal("health_changed", health)

func damage(amount):
	health = Helpers.approach(health, 0, amount)
	
	emit_signal("health_changed", health)
	
	if health == 0:
		emit_signal("death")