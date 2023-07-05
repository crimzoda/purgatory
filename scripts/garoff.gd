extends CharacterBody3D


const SPEED = 2
const JUMP_VELOCITY = 4.5

var type = "garoff"
var following = null
var state = "roaming"
var health = 500
var holding_axe = true
var axe = null
var can_shoot = true
var spirits = 100

var carcass_scene = load("res://entities/carcass.tscn")

var path = []
var path_ind = 0
@onready var amap = get_parent().get_node("NavigationRegion3D")

var damage_sound = load("res://sound/garoff_damage.ogg")
var roaming_sound = load("res://sound/garoff_roaming.ogg")
var death_sound = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	$pb_health.visible = $VisibleOnScreenNotifier3D.is_on_screen()
	$pb_health.value = health
	$health_bar.scale.x = (float(health) / 500) * 5

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if following != null and axe == null:
		$RayCast3D.target_position = following.global_position - $RayCast3D.global_position
		if $RayCast3D.is_colliding():
			var hit_collider = $RayCast3D.get_collider()
			
			if hit_collider == following and can_shoot == true:
				if global_position.distance_to(hit_collider.global_transform.origin) > 0.5:
					set_state("chasing")
					$NavigationAgent3D.target_position = following.global_position
					var current_location = global_transform.origin
					var next_location = $NavigationAgent3D.get_next_path_position()
					var new_velocity = (next_location - current_location).normalized() * SPEED
					velocity = new_velocity
						
					move_and_slide()
			else:
				following = null
	else:
		$RayCast3D.target_position = global_position - $RayCast3D.global_position	
		if state == "roaming":
			if global_transform.origin.distance_to($NavigationAgent3D.get_final_position()) < 5 or $NavigationAgent3D.target_position == Vector3.ZERO or int(velocity.length()) == 0:
				var target
				if axe == null:
					target = Vector3i(randi_range(global_transform.origin.x - 10, global_transform.origin.x + 10), global_transform.origin.y, randi_range(global_transform.origin.z - 10, global_transform.origin.z + 10))
				else:
					target = axe.global_transform.origin
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
	
	#$Area3D.look_at(transform.origin + velocity, Vector3.UP)
	#print(str($NavigationAgent3D.target_position))

func set_state(ind):
	match ind:
		"roaming":
			state = "roaming"
			#$Sprite3D.texture = load("res://textures/rat.png")
		"idle":
			state = "idle"
			$NavigationAgent3D.target_position = Vector3.ZERO
			velocity = Vector3.ZERO
			#$Sprite3D.texture = load("res://sprite_animations/rat_idle.png")
		"chasing":
			state = "chasing"
			#$Sprite3D.texture = load("res://textures/rat.png")
			

func _on_area_3d_body_entered(body):
	if body.get("type") == "player":
		following = body

func _on_damage_timer_timeout():
	if following != null and global_position.distance_to(following.global_position) < 2 and axe == null:
		$AudioStreamPlayer3D.stream = load("res://sound/garoff_axe_swing.ogg")
		$AudioStreamPlayer3D.play()
		$Sprite3D.texture = load("res://textures/garoff_melee_swing_axe.png")
		await get_tree().create_timer(0.5).timeout
		$AudioStreamPlayer3D.stream = load("res://sound/garoff_axe_impact.ogg")
		$AudioStreamPlayer3D.play()
		$Sprite3D.texture = load("res://textures/garoff_melee_finish_axe.png")
		if global_position.distance_to(following.global_position) < 2:
			following.damage(20)
		set_physics_process(false)
		await get_tree().create_timer(1).timeout
		set_physics_process(true)
		$Sprite3D.texture = load("res://textures/garoff_holding_axe.png")
		#$AnimationPlayer.play("rat_attack")


func _on_state_changer_timeout():
	if following == null:
		var states = ["idle", "roaming"]
		var state_choice = states[randi() % states.size()]
		match state_choice:
			"idle":
				set_state("idle")
			"roaming":
				set_state("roaming")
	$state_changer.wait_time = randi_range(5, 20)

func damage(amount):
	if health > 0:
		health -= amount
		$AudioStreamPlayer3D.stream = damage_sound
		$AudioStreamPlayer3D.play()
	else:
		var item_drop_scene = load("res://objects/item_drop.tscn")
		var item_drop = item_drop_scene.instantiate()
		item_drop.item_name = "dungeon_key"
		item_drop.global_position = Vector3(global_position.x, global_position.y + 0.5, global_position.z)
		get_parent().add_child(item_drop)
		PlayerInventory.add_item("spirit", spirits)
		
		var carcass = carcass_scene.instantiate()
		
		if axe == null:
			carcass.texture = load("res://textures/garoff_holding_axe_carcass.png")
		elif axe != null:
			axe.queue_free()
			carcass.texture = load("res://textures/garoff_carcass.png")
		carcass.audio = death_sound
		carcass.flip_h = $Sprite3D.flip_h
		carcass.global_transform.origin = global_transform.origin
		get_parent().add_child(carcass)
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


func _on_axe_timer_timeout():
	if axe == null and global_transform.origin.distance_to(Globals.player.global_transform.origin) > 3.5 and $RayCast3D.get_collider() == Globals.player:
		$Sprite3D.texture = load("res://textures/garoff_swing_axe.png")
		await get_tree().create_timer(0.5).timeout
		$Sprite3D.texture = load("res://textures/garoff_no_axe.png")
		var axe_projectile_scene = load("res://objects/garoff_axe.tscn")
		var axe_projectile = axe_projectile_scene.instantiate()
		axe_projectile.destination = Globals.player.global_transform.origin
		axe_projectile.garoff = self
		axe_projectile.global_position = global_position
		get_parent().add_child(axe_projectile)
