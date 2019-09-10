extends Node2D

const BulletTrail = preload("res://effects/bullet_trail/BulletTrail.tscn")

var holder = null

export(String) var item = null
onready var metadata = Global.database["items"][item]

var cold = true
onready var ammo = metadata["clip_size"]

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
				if ammo > 0:
					match(metadata["action"]):
						"semi_automatic":
							if Input.is_action_just_pressed("combat_attack") and cold:
								use()
						"automatic":
							if Input.is_action_pressed("combat_attack") and cold:
								use()
				else:
					if Input.is_action_just_pressed("combat_attack") and cold:
						reload()
			State.Reloading:
				pass

func transition(new_state):
	state = new_state

func use():
	assert(item != null)
	assert(metadata is Dictionary)
	
	ammo = Helpers.approach(ammo, 0, 1)
	
	for projectile in range(metadata["projectiles_per_shot"]):		
		# Calculate the initial angle of this shot based on
		# the angle of the equipment relative to the player
		var angle = position.angle()
		
		if metadata["projectiles_per_shot"] - 1 > 0:
			# Calculate the increment at which the ray should spread out
			var slice : float = (metadata["spread"] / metadata["projectiles_per_shot"])
			slice += slice / (metadata["projectiles_per_shot"] - 1)
			
			var offset = (slice * projectile) - (metadata["spread"] / 2)
			angle += deg2rad(offset)
		
		# Apply that to the angle of this projectile
		angle += deg2rad(rand_range(-metadata["variance"], metadata["variance"]))
		
		# Use the angle to calculate the initial destination of this shot
		var destination = Vector2(cos(angle), sin(angle)) * metadata["range"]
		
		# Collide the ray with the rest of the scene tree
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(
			global_position,
			global_position + destination,
			[ self ]
		)
		
		# Create a trail for this projectile
		var instance : Line2D = BulletTrail.instance()
		instance.points[1] = destination
		
		if result:
			instance.points[1] = result["position"] - global_position
		
		add_child(instance)
	
	heat_up()

func reload():
	transition(State.Reloading)
	holder.transition(holder.State.Reloading)
	
	yield(get_tree().create_timer(metadata["reload_time"]), "timeout")
	
	ammo = metadata["clip_size"] - ammo
	transition(State.Drawn)
	holder.transition(holder.State.Aiming)

func heat_up():
	assert(metadata is Dictionary)
	
	cold = false
	yield(get_tree().create_timer(metadata["cooldown"]), "timeout")
	cold = true