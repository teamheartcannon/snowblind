extends "res://characters/enemies/Enemy.gd"

export var movement_speed = 16.0
export var vision_radius = 24.0
export var attack_distance = 12.0
export var attack_speed = 1.0

var direction = Vector2.DOWN

enum State {
	Normal,
	Patrol,
	Alert
}
var state = State.Normal
var transitioning = false

func _ready():
	connect("enemy_hurt", self, "_on_EnemyZombie_hurt")
	connect("enemy_killed", self, "_on_EnemyZombie_killed")

func _process(delta):
	match(state):
		State.Normal:
			if not transitioning:
				transition(State.Patrol, 1.0)
		State.Patrol:
			move_and_slide(direction * movement_speed)
			
			if not transitioning:
				transition(State.Normal, 1.0) 

func transition(next_state, delay=null):
	transitioning = true
	
	if delay is float:
		yield(get_tree().create_timer(delay), "timeout")
	
	state = next_state
	transitioning = false