extends Control

var item = null
var sell_price = 0

func show_menu(menu_position, inventory_item, item_sell_price):
	global_position = menu_position
	item = inventory_item
	sell_price = item_sell_price
	visible = true
	
	if JsonData.item_data[PlayerInventory.inventory[item][0]]["Equippable"] == false:
		$VBoxContainer/btnEquip.visible = false
	else:
		$VBoxContainer/btnEquip.visible = true
	
	if Globals.player.equipped_item == item or Globals.player.offhand_item == item:
		$VBoxContainer/btnEquip.text = "Unequip"
		$VBoxContainer/btnEquip.icon = load("res://textures/item_equipped.png")
	else:
		$VBoxContainer/btnEquip.text = "Equip"
		$VBoxContainer/btnEquip.icon = load("res://textures/equip_item.png")
	
	if JsonData.item_data[PlayerInventory.inventory[item][0]]["ItemCategory"] == "Food":
		$VBoxContainer/btnConsume.visible = true
	else:
		$VBoxContainer/btnConsume.visible = false
	
	if Globals.player.can_trade == true:
		$VBoxContainer/btnSell.visible = true
	else:
		$VBoxContainer/btnSell.visible = false
		
	if Globals.player.item_slot_1 == item:
		$VBoxContainer/btnEquipPrimary.text = "Unequip primary"
		$VBoxContainer/btnEquipSecondary.text = "Equip secondary"
		$VBoxContainer/btnEquipPrimary.icon = load("res://textures/equipped_slot_1.png")
		$VBoxContainer/btnEquipSecondary.icon = load("res://textures/equip_slot_2.png")
	else:
		$VBoxContainer/btnEquipPrimary.text = "Equip primary"
		$VBoxContainer/btnEquipPrimary.icon = load("res://textures/equip_slot_1.png")
	if Globals.player.item_slot_2 == item:
		$VBoxContainer/btnEquipSecondary.text = "Unequip secondary"
		$VBoxContainer/btnEquipPrimary.text = "Equip primary"
		$VBoxContainer/btnEquipSecondary.icon = load("res://textures/equipped_slot_2.png")
		$VBoxContainer/btnEquipPrimary.icon = load("res://textures/equip_slot_1.png")
	else:
		$VBoxContainer/btnEquipSecondary.text = "Equip secondary"
		$VBoxContainer/btnEquipSecondary.icon = load("res://textures/equip_slot_2.png")

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
	
	# Taking into account slot stuff
	if Globals.player.item_slot_1 == item:
		Globals.player.item_slot_1 = null
	if Globals.player.item_slot_2 == item:
		Globals.player.item_slot_2 = null
	visible = false


func _on_btn_equip_pressed():
	if Globals.player.equipped_item == item:
		Globals.player.equipped_item = null
	elif Globals.player.offhand_item == item:
		Globals.player.offhand_item = null
	elif Globals.player.torso == item:
		Globals.player.torso = null
	else:
		Globals.player.equip_item(item)
	visible = false


func _on_btn_consume_pressed():
	if Globals.player.health < Globals.player.max_health:
		Globals.player.health = Globals.player.health + JsonData.item_data[PlayerInventory.inventory[item][0]]["Health_buff"]
		PlayerInventory.inventory[item][1] = PlayerInventory.inventory[item][1] - 1
		if PlayerInventory.inventory[item][1] <= 0:
			PlayerInventory.inventory.erase(item)
	visible = false


func _on_btn_equip_primary_pressed():
	if Globals.player.item_slot_1 == item:
		Globals.player.item_slot_1 = null
	else:
		if Globals.player.equipped_item == Globals.player.item_slot_1:
			Globals.player.item_slot_1 = item
			Globals.player.equip_item(Globals.player.item_slot_1)
		else:
			Globals.player.item_slot_1 = item
		if Globals.player.item_slot_2 == item:
			Globals.player.item_slot_2 = null
	visible = false


func _on_btn_equip_secondary_pressed():
	if Globals.player.item_slot_2 == item:
		Globals.player.item_slot_2 = null
	else:
		if Globals.player.equipped_item == Globals.player.item_slot_2:
			Globals.player.item_slot_2 = item
			Globals.player.equip_item(Globals.player.item_slot_2)
		else:
			Globals.player.item_slot_2 = item
		if Globals.player.item_slot_1 == item:
			Globals.player.item_slot_1 = null
	visible = false


func _on_btn_sell_pressed():
	if Globals.player.equipped_item == item:
		Globals.player.equipped_item = null
	PlayerInventory.inventory.erase(item)
	PlayerInventory.add_item("spirit", sell_price)
