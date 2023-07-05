extends CharacterBody3D


const SPEED = 2
const JUMP_VELOCITY = 4.5

var type = "siriph"
var following = null
var health = 100

var carcass_scene = load("res://entities/carcass.tscn")

var shopItem = load("res://ui/shop_item.tscn")
var max_items = 10

var path = []
var path_ind = 0
@onready var amap = get_parent().get_node("NavigationRegion3D")

var roaming_sound = load("res://sound/skeleton_roaming.ogg")
var damage_sound = load("res://sound/skeleton_damage.ogg")
var death_sound = load("res://sound/skeleton_death.ogg")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	max_items = randi_range(5, 10)
	for item in max_items:
		var shopLoot = shopItem.instantiate()
		var rand = randi_range(0, JsonData.item_data.size())
		var index = 0
		for i in JsonData.item_data:
			index += 1
			if rand == index and JsonData.item_data[i].has("Price"):
				shopLoot.item_name = i
				shopLoot.item_quantity = randi_range(1, JsonData.item_data[i]["StackSize"])
				var price_range_diff = int(int(JsonData.item_data[i]["Price"]) % 2)
				shopLoot.item_price = randi_range(JsonData.item_data[i]["Price"] - price_range_diff, JsonData.item_data[i]["Price"] + price_range_diff)
				$Shop_window/ScrollContainer/storageContainer.add_child(shopLoot)
					

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if $Shop_window.visible == false:
		if global_transform.origin.distance_to($NavigationAgent3D.get_final_position()) < 5 or $NavigationAgent3D.target_position == Vector3.ZERO or int(velocity.length()) == 0:
			var target = Vector3i(randi_range(global_transform.origin.x - 20, global_transform.origin.x + 20), global_transform.origin.y, randi_range(global_transform.origin.z - 20, global_transform.origin.z + 20))
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
		
	$Label3D.text = "velocity: " + str(int(velocity.length()))
	#print(str($NavigationAgent3D.target_position))

func _on_area_3d_body_entered(body):
	if body.get("type") == "player":
		following = body

func open():
	pass
	
func close():
	pass

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if (event.pressed and event.button_index == MOUSE_BUTTON_LEFT 
		and Globals.player.global_transform.origin.distance_to(global_transform.origin) < 2):
				$Shop_window.visible = !$Shop_window.visible


func _on_audio_timer_timeout():
	$AudioStreamPlayer3D.stream = roaming_sound
	$AudioStreamPlayer3D.play()
	$audio_timer.wait_time = randi_range(1, 5)
