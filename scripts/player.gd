extends CharacterBody3D

var SPEED = 7.0
var roll = 0
var stamina = 100
var invulnerable = false
const JUMP_VELOCITY = 4.5

var type = "player"
var max_health = 100
var health = 100

var equipped_item = null
var offhand_item = null
var can_hit = true
var can_trade = false
var item_slot_1 = null
var item_slot_2 = null
var torso = null
var head = null

var base_damage = 5
var base_range = 1
var dmg = 5
var range = 1
var dead = false

var state = "normal"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Globals.player = self

func death_screen():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _process(delta):
	
	$stats/health_bar.scale.x = float(health) / 100
	$stats/stamina_bar.scale.x = float(stamina) / 100
	
	if torso != null:
		$wearable_torso.texture = load("res://textures/wearables/" + PlayerInventory.inventory[torso][0] + "_" + state + ".png")
	else:
		$wearable_torso.texture = null
	if head != null:
		$wearable_head.texture = load("res://textures/wearables/" + PlayerInventory.inventory[head][0] + "_" + state + ".png")
	else:
		$wearable_head.texture = null
		
	if health <= 0:
		if dead == false:
			dead = true
			get_parent().get_node("Camera3D").global_position = get_node("Camera3D").global_position
			get_parent().get_node("Camera3D").global_rotation = get_node("Camera3D").global_rotation
			get_parent().get_node("Camera3D").current = true
			get_node("Camera3D").current = false
			global_position = Vector3(-100, -100, -100)
			$AnimationPlayer.play("death_fade")
	elif health > max_health:
		health = max_health

	if equipped_item != null and $equippedHand.get_child_count() == 0:
		var item_scene = load("res://objects/" + PlayerInventory.inventory[equipped_item][0] + ".tscn")
		var item = item_scene.instantiate()
		item.item = equipped_item
		$equippedHand.add_child(item)
	if equipped_item == null and $equippedHand.get_child_count() == 1:
		$equippedHand.get_child(0).queue_free()
	if offhand_item != null and $offhand.get_child_count() == 0:
		var item_scene = load("res://objects/" + PlayerInventory.inventory[offhand_item][0] + ".tscn")
		var item = item_scene.instantiate()
		item.item = offhand_item
		$offhand.add_child(item)
	if offhand_item == null and $offhand.get_child_count() == 1:
		$offhand.get_child(0).queue_free()
	
	if item_slot_1 != null:
		$Control/HBoxContainer/item_slot_1/item.texture = load("res://textures/items/" + PlayerInventory.inventory[item_slot_1][0] + ".png")
	else:
		$Control/HBoxContainer/item_slot_1/item.texture = null
	if item_slot_2 != null:
		$Control/HBoxContainer/item_slot_2/item.texture = load("res://textures/items/" + PlayerInventory.inventory[item_slot_2][0] + ".png")
	else:
		$Control/HBoxContainer/item_slot_2/item.texture = null
		
func _physics_process(delta):
	SPEED = 7.0 + roll
	# Add the gravity.
	if not is_on_floor() and health > 0:
		velocity.y -= gravity * delta
		print("going down")

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("equip_1") and item_slot_1 != null:
		equip_item(item_slot_1)
		$Control/HBoxContainer/item_slot_2/slot_num.texture = load("res://textures/equip_slot_2.png")
		$Control/HBoxContainer/item_slot_1/slot_num.texture = load("res://textures/equipped_slot_1.png")
	if Input.is_action_just_pressed("equip_2") and item_slot_2 != null:
		equip_item(item_slot_2)
		$Control/HBoxContainer/item_slot_1/slot_num.texture = load("res://textures/equip_slot_1.png")
		$Control/HBoxContainer/item_slot_2/slot_num.texture = load("res://textures/equipped_slot_2.png")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if (Input.is_action_pressed("ui_left")):
		get_node( "Sprite3D" ).set_flip_h( true )
		get_node( "wearable_torso" ).set_flip_h( true )
		get_node( "wearable_head" ).set_flip_h( true )
		if $equippedHand.get_child_count() == 1:
			$equippedHand.get_child(0).flip("left")
		if $offhand.get_child_count() == 1:
			$offhand.get_child(0).flip("left")
	elif (Input.is_action_pressed("ui_right")):
		get_node( "Sprite3D" ).set_flip_h( false )
		get_node( "wearable_torso" ).set_flip_h( false )
		get_node( "wearable_head" ).set_flip_h( false )
		if $equippedHand.get_child_count() == 1:
			$equippedHand.get_child(0).flip("right")
		if $offhand.get_child_count() == 1:
			$offhand.get_child(0).flip("right")
	
	if (Input.is_action_just_pressed("roll")) and stamina > 0:
		roll = 5
		stamina = stamina - 20
		invulnerable = true
		state = "roll"
		$AnimationPlayer.play("roll")
		$Sprite3D.modulate.a = 0.5
		$roll_timer.start()
	
	if (Input.is_action_just_pressed("player_info")):
		$stats.visible = !$stats.visible
	
	if stamina < 0:
		stamina = 0
	
	$Label3D.text = "Stamina: " + str(stamina)

func equip_item(item):
	var item_name = PlayerInventory.inventory[item][0]
	
	if JsonData.item_data[item_name]["ItemCategory"] == "Offhand": 
		offhand_item = item
	else:
		if JsonData.item_data[item_name]["ItemCategory"] != "Wearable":
			if $equippedHand.get_child_count() > 0:
				$equippedHand.get_child(0).queue_free()
			equipped_item = item
		dmg = base_damage
		range = base_range
		if JsonData.item_data[item_name]["ItemCategory"] == "Weapon":
			dmg = base_damage + JsonData.item_data[item_name]["Damage"]
			range = base_range + JsonData.item_data[item_name]["Range"]
			can_hit = true
			print("damage: " + str(dmg) + ", range: " + str(range))
		elif JsonData.item_data[item_name]["ItemCategory"] == "Projectile":
			dmg = 0
			range = 0
			can_hit = false
			print("equipped a projectile")
		if JsonData.item_data[item_name]["ItemCategory"] == "Wearable":
			if JsonData.item_data[item_name]["Body_Part"] == "Torso":
				torso = item
			if JsonData.item_data[item_name]["Body_Part"] == "Head":
				head = item
	print(str(equipped_item))

func get_mouse_3d():
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_node("Camera3D")
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	var ray_array = space_state.intersect_ray(params)
	if ray_array.has("position"):
		return Vector3(ray_array["position"].x, global_position.y, ray_array["position"].z)
	

func damage(amount):
	if invulnerable == false:
		health -= amount
		$AnimationPlayer.play("damage")

func _on_roll_timer_timeout():
	roll = 0
	invulnerable = false
	$AnimationPlayer.play("RESET")
	$Sprite3D.modulate.a = 1
	state = "normal"

func _on_stamina_cooldown_timeout():
	if stamina < 100:
		stamina = stamina + 10
	else:
		stamina = 100
