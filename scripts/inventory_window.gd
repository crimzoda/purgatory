extends Control

var dragPoint = null

var inventoryItem = load("res://ui/inventory_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for inventory_item in $ScrollContainer/inventoryContainer.get_children():
		inventory_item.queue_free()
		# Remove child takes memory up, it doesn't completely destroy the item
		# it removes it from the tree but not from memory!!
		#$ScrollContainer/inventoryContainer.remove_child(inventory_item)
	for item in PlayerInventory.inventory:
		var inv_item = inventoryItem.instantiate()
		inv_item.item = item
		$ScrollContainer/inventoryContainer.add_child(inv_item)
	
	$lblSpirits.text = str(PlayerInventory.spirits)

func _input(event):
	#TOGGLING THE WINDOWS VISIBILITY
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible

func _on_dragbar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragPoint = get_global_mouse_position() - get_parent().get_node("Inventory_window").get_position()
			else:
				dragPoint = null
	if event is InputEventMouseMotion and dragPoint != null:
		get_parent().get_node("Inventory_window").set_position(get_global_mouse_position() - dragPoint)


func _on_close_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				get_parent().get_node("Inventory_window").visible = !get_parent().get_node("Inventory_window").visible


func _on_visibility_changed():
	$AudioStreamPlayer.stream = load("res://sound/inventory.ogg")
	$AudioStreamPlayer.play()


func _on_area_2d_mouse_entered():
	Globals.player.can_hit = false
	print("mouse entered")


func _on_area_2d_mouse_exited():
	Globals.player.can_hit = true
	print("mouse exited")


func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event.is_action_pressed("interact") or event.is_action_pressed("click")) and $context_menu.visible == true:
		$context_menu.visible = false
		print("da")
