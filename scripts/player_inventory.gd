extends Node


#INVENTORY STRUCTURE: { INDEX: [ITEM_NAME, ITEM_AMOUNT, [STORAGE_TYPE, ITEM_QUALITY]] }
#IF THE STORAGE IS IN THE STORAGE_TYPE IS NULL, IF THE ITEM DOESN'T HAVE A QUALITY PROPERTY...
#ITEM_QUALITY IS NULL
var inventory = { 0: ["torch", 1], 1: ["dagger", 1], 2: ["crossbow", 1], 3: ["guard_helmet", 1] }
var inventory_space = 15
var itemdropload = load("res://objects/item_drop.tscn")

var spirits = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_item(item_name, item_quantity):
	if item_name != "spirit":
		#IF THERE IS ALREADY THE SAME ITEM
		for item in inventory:
			if inventory[item][0] == item_name:
				var stack_size = int(JsonData.item_data[item_name]["StackSize"])
				var able_to_add = stack_size - inventory[item][1]
				if able_to_add >= item_quantity:
					inventory[item][1] += item_quantity
					return
				else:
					inventory[item][1] += able_to_add
					item_quantity = item_quantity - able_to_add
				
		#IF THERE IS NO ITEMS THAT ARE THE SAME		
		for i in range(inventory_space):
			if inventory.has(i) == false:
				inventory[i] = [item_name, item_quantity]
				return
	else:
		PlayerInventory.spirits = PlayerInventory.spirits + item_quantity
		
			
func dropItem(dropname, dropamount):
	for i in dropamount:
		var drop = itemdropload.instantiate()
		if dropamount > 1:
			drop.global_transform.origin = Vector3(randf_range(Globals.player.global_transform.origin.x - 1, Globals.player.global_transform.origin.x + 1), Globals.player.global_transform.origin.y, randf_range(Globals.player.global_transform.origin.z - 1, Globals.player.global_transform.origin.z + 1))
		else:
			drop.global_position = Globals.player.global_position
		drop.item_name = dropname
		get_parent().add_child(drop)
