extends Control

var item_name
var item_quantity
var item_price

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/HBoxContainer/itemTexture.texture = load("res://textures/items/" + item_name + ".png")
	$ColorRect/HBoxContainer/txtItemName.text =  item_name.replace('_', ' ')
	$ColorRect/HBoxContainer/txtItemAmount.text = "(" + str(item_quantity) + ")"
	$ColorRect/HBoxContainer/btnBuy.text = str(item_price)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if item_price > PlayerInventory.spirits:
		$ColorRect/HBoxContainer/btnBuy.disabled = true
	else:
		$ColorRect/HBoxContainer/btnBuy.disabled = false

func _on_btn_loot_pressed():
	PlayerInventory.add_item(item_name, 1)
	PlayerInventory.spirits = PlayerInventory.spirits - item_price
	item_quantity = item_quantity - 1
	$ColorRect/HBoxContainer/txtItemAmount.text = "(" + str(item_quantity) + ")"
	if item_quantity == 0:
		queue_free()
