extends Node3D
var item

func  _ready():
	$AnimationPlayer.play("torch_flicker")

func  _process(delta):
	if Input.is_action_just_pressed("roll"):
		if randi_range(0, 50) < 10:
			#DROPPING INVENTORY ITEM
			Globals.player.offhand_item = null
			#PlayerInventory.dropItem(PlayerInventory.inventory[item][0],  PlayerInventory.inventory[item][1])
			PlayerInventory.inventory[item][1] = PlayerInventory.inventory[item][1] - 1
			if Globals.player.item_slot_1 == item:
				Globals.player.item_slot_1 = null
			if Globals.player.item_slot_2 == item:
				Globals.player.item_slot_2 = null
			queue_free()

func flip(direction):
	if direction == "right":
		$Sprite3D.set_flip_h(true)
		scale.x = -1
		transform.origin = Vector3(.266, 0, 0)
	else:
		$Sprite3D.set_flip_h(false)
		scale.x = 1
		transform.origin = Vector3(0, 0, 0)
