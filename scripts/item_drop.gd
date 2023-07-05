extends CharacterBody3D

const MAX_SPEED = 100
const ACCELERATION = 200
@export var item_name = "screwdriver"
var being_picked_up = false

func _ready():
	$AnimationPlayer.play("item_drop")
	$itemSprite.texture = load("res://textures/items/" + item_name + ".png")
	
	await get_tree().create_timer(480).timeout
	queue_free()

func _physics_process(delta):
	if being_picked_up == true:
		var direction = global_transform.origin.direction_to(Globals.player.global_transform.origin)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		
		var distance = global_transform.origin.distance_to(Globals.player.global_transform.origin)
		if distance < 1.5:
			PlayerInventory.add_item(item_name, 1)
			queue_free()
		move_and_slide()



func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("interact") and global_transform.origin.distance_to(Globals.player.global_transform.origin) < 3:
		being_picked_up = true
