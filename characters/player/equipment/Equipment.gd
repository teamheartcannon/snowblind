extends Node2D

const BulletTrail = preload("res://effects/bullet_trail/BulletTrail.tscn")
const Enemy = preload("res://characters/enemies/Enemy.gd")

var holder = null

export(String) var item = null
onready var metadata = Global.database["items"][item] if item != null else null

var cold = true
onready var ammo = metadata["clip_size"] if item != null else 0

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
						if holder.inventory.has_item(metadata["ammo_type"]):
							reload()
						else:
							if metadata.has("sounds"):
								if metadata["sounds"].has("dry_fire"):
									AudioSystem.play(metadata["sounds"]["dry_fire"])
			State.Reloading:
				pass

func transition(new_state):
	state = new_state

func set_item(item):
	assert(Global.database["items"].has[item])
	
	item = item
	metadata = Global.database["items"][item]

func use():
	assert(item != null)
	assert(metadata is Dictionary)
	
	ammo = Helpers.approach(ammo, 0, 1)
	
	if metadata.has("sounds"):
		if metadata["sounds"].has("attack"):
			AudioSystem.play(metadata["sounds"]["attack"])
	
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
			
			if result["collider"] is Enemy:
				var enemy = result["collider"] as Enemy
				enemy.damage(33)
		
		add_child(instance)
	
	heat_up()

func reload():
	assert(holder.inventory.has_item(metadata["ammo_type"]))
	
	transition(State.Reloading)
	holder.transition(holder.State.Reloading)
	
	if metadata.has("sounds"):
		if metadata["sounds"].has("reload"):
			AudioSystem.play(metadata["sounds"]["reload"])
	
	yield(get_tree().create_timer(metadata["reload_time"]), "timeout")
	
	var difference = metadata["clip_size"] - ammo
	holder.inventory.remove_item(metadata["ammo_type"], difference)
	
	ammo = metadata["clip_size"]
	
	transition(State.Drawn)
	holder.transition(holder.State.Aiming)

func heat_up():
	assert(metadata is Dictionary)
	
	cold = false
	yield(get_tree().create_timer(metadata["cooldown"]), "timeout")
	cold = true