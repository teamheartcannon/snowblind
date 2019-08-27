extends KinematicBody2D

export var move_acceleration_time = 4.0
export var move_speed = 8.0
onready var move_acceleration = move_speed / move_acceleration_time
var move_velocity : Vector2

func _ready():
	assert(move_speed > 0.0)
	assert(move_acceleration_time)
	print(move_acceleration)

func _physics_process(delta):
	var move_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		move_direction.y -= 1.0
	elif Input.is_action_pressed("move_down"):
		move_direction.y += 1.0
		
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1.0
	elif Input.is_action_pressed("move_right"):
		move_direction.x += 1.0
	
	move_direction *= move_acceleration
	
	move_velocity = move_and_slide(move_direction)