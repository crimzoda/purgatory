extends Control

var item_name
var item_quantity

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/HBoxContainer/itemTexture.texture = load("res://textures/items/" + item_name + ".png")
	$ColorRect/HBoxContainer/txtItemName.text =  item_name.replace('_', ' ')
	$ColorRect/HBoxContainer/txtItemAmount.text = "(" + str(item_quantity) + ")"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_btn_loot_pressed():
	PlayerInventory.add_item(item_name, item_quantity)
	queue_free()
