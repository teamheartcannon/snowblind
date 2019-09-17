extends "res://characters/enemies/Enemy.gd"

const BloodPool = preload("res://effects/gore/blood_pool/BloodPool.tscn")

export var movement_speed = 16.0
export var vision_radius = 32.0
export var attack_distance = 12.0
export var attack_speed = 1.0

var direction = Vector2.DOWN

enum State {
	Normal,
	Patrol,
	Alert
}
var state = State.Patrol
var transitioning = false
var thinking = false

onready var sounds = {
	"call": [
		"res://characters/enemies/zombie/ZombieCallJP1.wav",
		"res://characters/enemies/zombie/ZombieCallJP2.wav",
		"res://characters/enemies/zombie/ZombieCallJP3.wav",
		"res://characters/enemies/zombie/ZombieCallJP4.wav",
		"res://characters/enemies/zombie/ZombieCallJP5.wav",
		"res://characters/enemies/zombie/ZombieCallJP6.wav"
	],
	"hit": [
		"res://characters/enemies/zombie/ZombieHitJP1.wav",
		"res://characters/enemies/zombie/ZombieHitJP2.wav",
		"res://characters/enemies/zombie/ZombieHitJP3.wav",
		"res://characters/enemies/zombie/ZombieHitJP4.wav"
	]
}

onready var player = get_node("/root/Game/YSort/Player")

func _ready():
	connect("enemy_hurt", self, "_on_EnemyZombie_hurt")
	connect("enemy_killed", self, "_on_EnemyZombie_killed")

func _process(delta):
	match(state):
		State.Patrol:
			move_and_slide(direction * movement_speed)
			
			if not thinking:
				thinking = true
				yield(get_tree().create_timer(rand_range(1.0, 4.0)), "timeout")
				direction = random_direction()
				thinking = false
			
			if global_position.distance_to(player.global_position) < vision_radius:
				transition(State.Alert)
		State.Alert:
			direction = global_position.direction_to(player.global_position)
			
			move_and_slide(direction * movement_speed)
			
			if global_position.distance_to(player.global_position) > vision_radius:
				transition(State.Patrol)

func _on_EnemyZombie_hurt():
	if state != State.Alert:
		transition(State.Alert)
	
	AudioSystem.play(sounds["hit"], global_position)

func _on_EnemyZombie_killed():
	# Create a pool of blood where the zombie died
	var blood_pool = BloodPool.instance()
	blood_pool.global_position = global_position
	get_tree().root.add_child(blood_pool)
	
	queue_free()

func random_direction():
	var dir = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	
	return dir

func transition(next_state, delay=null):
	transitioning = true
	
	if delay is float:
		yield(get_tree().create_timer(delay), "timeout")
	
	match(next_state):
		State.Alert:
			AudioSystem.play(sounds["call"], global_position)
	
	state = next_state
	transitioning = false