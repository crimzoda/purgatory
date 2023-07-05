extends Node3D

var storageItem = load("res://ui/storage_item.tscn")
var max_items = 10

var dragPoint

func _ready():
	max_items = randi_range(5, 10)
	for item in max_items:
		var storageLoot = storageItem.instantiate()
		var rand = randi_range(0, JsonData.item_data.size())
		var index = 0
		for i in JsonData.item_data:
			index += 1
			if rand == index:
				var dropPercent = randi_range(1, 100)
				print(str(i) + " : " + str(dropPercent) + "%")
				if JsonData.item_data[i]["Drop_Chance"] > 0 and dropPercent <= JsonData.item_data[i]["Drop_Chance"]:
					storageLoot.item_name = i
					storageLoot.item_quantity = randi_range(1, JsonData.item_data[i]["StackSize"])
					$Chest_window/ScrollContainer/storageContainer.add_child(storageLoot)

func open():
	$AnimationPlayer.play("chest_open")

func close():
	$AnimationPlayer.play("chest_close")

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("interact") and global_position.distance_to(Globals.player.global_position) < 5:
		$Chest_window.visible = !$Chest_window.visible
		$AudioStreamPlayer3D.stream = load("res://sound/chest_interact.ogg")
		$AudioStreamPlayer3D.play()


func _on_area_2d_mouse_entered():
	Globals.player.can_hit = false
	print("mouse entered")


func _on_area_2d_mouse_exited():
	Globals.player.can_hit = true
	print("mouse entered")
