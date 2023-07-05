extends Control

var item
var equipped = false
var sell_price = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/HBoxContainer/itemTexture.texture = load("res://textures/items/" + PlayerInventory.inventory[item][0] + ".png")
	$ColorRect/HBoxContainer/txtItemName.text =  PlayerInventory.inventory[item][0].replace('_', ' ')
	$ColorRect/HBoxContainer/txtItemAmount.text = "(" + str( PlayerInventory.inventory[item][1]) + ")"
	
	tooltip_text = JsonData.item_data[PlayerInventory.inventory[item][0]]["Description"]
	
	var price_range_diff = int(int(JsonData.item_data[PlayerInventory.inventory[item][0]]["Price"]) % 2)
	sell_price = randi_range(JsonData.item_data[PlayerInventory.inventory[item][0]]["Price"] - price_range_diff, JsonData.item_data[PlayerInventory.inventory[item][0]]["Price"] + price_range_diff)
	
	if JsonData.item_data[PlayerInventory.inventory[item][0]]["Equippable"] == false:
		$ColorRect/HBoxContainer/btnEquip.visible = false
	
	if Globals.player.equipped_item == item or Globals.player.offhand_item == item:
		$ColorRect/HBoxContainer/btnEquip.icon = load("res://textures/item_equipped.png")
	else:
		$ColorRect/HBoxContainer/btnEquip.icon = load("res://textures/equip_item.png")
	
	if PlayerInventory.inventory[item][1] <= 0:
		PlayerInventory.inventory.erase(item)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_btn_drop_pressed():
	#DROPPING INVENTORY ITEM
	if Globals.player.equipped_item == item:
		Globals.player.equipped_item = null
		Globals.player.dmg = Globals.player.base_damage
		Globals.player.range = Globals.player.base_range
	if Globals.player.offhand_item == item:
		Globals.player.offhand_item = null
	if Globals.player.torso == item:
		Globals.player.torso = null
	if Globals.player.head == item:
		Globals.player.head = null
	PlayerInventory.dropItem(PlayerInventory.inventory[item][0],  PlayerInventory.inventory[item][1])
	PlayerInventory.inventory.erase(item)
	if Globals.player.item_slot_1 == item:
		Globals.player.item_slot_1 = null
	if Globals.player.item_slot_2 == item:
		Globals.player.item_slot_2 = null


func _on_btn_equip_pressed():
	if Globals.player.equipped_item == item:
		Globals.player.equipped_item = null
	elif Globals.player.offhand_item == item:
		Globals.player.offhand_item = null
	else:
		Globals.player.equip_item(item)

#
#func _on_btn_consume_pressed():
#	if Globals.player.health < Globals.player.max_health:
#		Globals.player.health = Globals.player.health + JsonData.item_data[PlayerInventory.inventory[item][0]]["Health_buff"]
#		PlayerInventory.inventory[item][1] = PlayerInventory.inventory[item][1] - 1
#		if PlayerInventory.inventory[item][1] <= 0:
#			PlayerInventory.inventory.erase(item)
#
#
#func _on_btn_sell_pressed():
#	if Globals.player.equipped_item == item:
#		Globals.player.equipped_item = null
#	PlayerInventory.inventory.erase(item)
#	PlayerInventory.add_item("spirit", sell_price)
#
#
#
#func _on_btn_put_slot_1_pressed():
#	if Globals.player.item_slot_1 == item:
#		Globals.player.item_slot_1 = null
#	else:
#		if Globals.player.equipped_item == Globals.player.item_slot_1:
#			Globals.player.item_slot_1 = item
#			Globals.player.equip_item(Globals.player.item_slot_1)
#		else:
#			Globals.player.item_slot_1 = item
#		if Globals.player.item_slot_2 == item:
#			Globals.player.item_slot_2 = null
#
#
#
#func _on_btn_put_slot_2_pressed():
#	if Globals.player.item_slot_2 == item:
#		Globals.player.item_slot_2 = null
#	else:
#		if Globals.player.equipped_item == Globals.player.item_slot_2:
#			Globals.player.item_slot_2 = item
#			Globals.player.equip_item(Globals.player.item_slot_2)
#		else:
#			Globals.player.item_slot_2 = item
#		if Globals.player.item_slot_1 == item:
#			Globals.player.item_slot_1 = null


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("interact"):
		get_parent().get_parent().get_parent().get_node("context_menu").show_menu(get_global_mouse_position(), item, sell_price)


func _on_area_2d_mouse_entered():
	if PlayerInventory.inventory.has(item):
		get_parent().get_parent().get_parent().get_node("item_texture").texture = load("res://textures/items/" + PlayerInventory.inventory[item][0] + ".png")
		get_parent().get_parent().get_parent().get_node("item_description").text = JsonData.item_data[PlayerInventory.inventory[item][0]]["Description"]
	else:
		get_parent().get_parent().get_parent().get_node("item_texture").texture = null
		get_parent().get_parent().get_parent().get_node("item_description").text = ""
		
func _on_area_2d_mouse_exited():
	get_parent().get_parent().get_parent().get_node("item_texture").texture = null
	get_parent().get_parent().get_parent().get_node("item_description").text = ""
