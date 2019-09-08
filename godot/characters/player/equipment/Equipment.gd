extends Node2D

export(String) var item = null
onready var metadata = Global.database["items"][item]

onready var bullet_trail = preload("res://effects/bullet_trail/BulletTrail.tscn")

var cold = true

enum State {
	Holstered,
	Drawn,
	Reloading
}
var state = State.Holstered

func _process(delta):
	if metadata is Dictionary:
		match(state):
			State.Holstered:
				pass
			State.Drawn:
				match(metadata["action"]):
					"semi_automatic":
						if Input.is_action_just_pressed("combat_attack") and cold:
							use()
					"automatic":
						if Input.is_action_pressed("combat_attack") and cold:
							use()
			State.Reloading:
				pass

func use():
	assert(item != null)
	assert(metadata is Dictionary)
	
	for pellet in range(metadata["pellets"]):
		# Calculate the initial angle of this shot based on
		# the angle of the equipment relative to the player
		var angle = position.angle()
		print(angle)
		
		if metadata["pellets"] - 1 > 0:
			# Calculate the increment at which the ray should spread out
			var slice : float = (metadata["spread"] / metadata["pellets"])
			
			slice += slice / (metadata["pellets"] - 1)
			var offset = (slice * pellet) - (metadata["spread"] / 2)
			angle += deg2rad(offset)
		
		# Apply that to the angle of this pellet
		#angle += deg2rad(rand_range(-metadata["variance"], metadata["variance"]))
		
		# Use the angle to calculate the initial destination of this shot
		var destination = Vector2(cos(angle), sin(angle)) * metadata["range"]
		
		# Collide the ray with the rest of the scene tree
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(
			global_position,
			global_position + destination,
			[ self ]
		)
		
		# Create a trail for this pellet
		var instance : Line2D = bullet_trail.instance()
		instance.points[1] = destination
		
		if result:
			print(result["position"])
			instance.points[1] = result["position"] - global_position
		
		add_child(instance)
	
	heat_up()

func heat_up():
	assert(metadata is Dictionary)
	
	cold = false
	yield(get_tree().create_timer(metadata["cooldown"]), "timeout")
	cold = true