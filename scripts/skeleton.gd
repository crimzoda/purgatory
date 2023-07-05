extends CharacterBody3D


const SPEED = 2
const JUMP_VELOCITY = 4.5

var type = "skeleton"
var following = null
var health = 100
var spirits = 2
var carcass_scene = load("res://entities/carcass.tscn")

var path = []
var path_ind = 0
@onready var amap = get_parent().get_node("NavigationRegion3D")

var roaming_sound = load("res://sound/skeleton_roaming.ogg")
var damage_sound = load("res://sound/skeleton_damage.ogg")
var death_sound = load("res://sound/skeleton_death.ogg")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if following != null:
		$RayCast3D.target_position = following.global_position - $RayCast3D.global_position
		if $RayCast3D.is_colliding():
			var hit_collider = $RayCast3D.get_collider()
			
			if hit_collider == following:
				if global_position.distance_to(hit_collider.global_position) > 0.5:
					velocity = position.direction_to(hit_collider.position) * SPEED
					move_and_collide(velocity * SPEED * delta)
			else:
				following = null
	else:
		$RayCast3D.target_position = global_position - $RayCast3D.global_position
				
		if global_transform.origin.distance_to($NavigationAgent3D.get_final_position()) < 5 or $NavigationAgent3D.target_position == Vector3.ZERO or int(velocity.length()) == 0:
			var target = Vector3i(randi_range(global_transform.origin.x - 10, global_transform.origin.x + 10), global_transform.origin.y, randi_range(global_transform.origin.z - 10, global_transform.origin.z + 10))
			$NavigationAgent3D.target_position = target
		
		var current_location = global_transform.origin
		var next_location = $NavigationAgent3D.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * SPEED
		velocity = new_velocity
		move_and_slide()
				
	if velocity.x > 0 and velocity.x > velocity.z:
		$Sprite3D.set_flip_h(false)
	elif velocity.x < 0 and velocity.x < velocity.z:
		$Sprite3D.set_flip_h(true)
	
	$Area3D.look_at(transform.origin + velocity, Vector3.UP)
	$Label3D.text = "velocity: " + str(int(velocity.length()))
	#print(str($NavigationAgent3D.target_position))

func _on_area_3d_body_entered(body):
	if body.get("type") == "player":
		following = body


func _on_damage_timer_timeout():
	if following != null and global_position.distance_to(following.global_position) < 1:
		following.damage(5)

func damage(amount):
	if health > 0:
		health -= amount
		$AnimationPlayer.play("skeleton_damage")
		$AudioStreamPlayer3D.stream = damage_sound
		$AudioStreamPlayer3D.play()
	else:
		var carcass = carcass_scene.instantiate()
		carcass.texture = load("res://textures/skeleton_carcass.png")
		carcass.audio = death_sound
		carcass.flip_h = $Sprite3D.flip_h
		carcass.global_transform.origin = global_transform.origin
		get_parent().add_child(carcass)
		PlayerInventory.add_item("spirit", spirits)
		queue_free()

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if (event.pressed and event.button_index == MOUSE_BUTTON_LEFT 
		and Globals.player.global_transform.origin.distance_to(global_transform.origin) < Globals.player.range
		and Globals.player.can_hit == true):
				damage(Globals.player.dmg)


func _on_audio_timer_timeout():
	$AudioStreamPlayer3D.stream = roaming_sound
	$AudioStreamPlayer3D.play()
	$audio_timer.wait_time = randi_range(1, 5)
