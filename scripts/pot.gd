extends StaticBody3D

var smashed = false
var type = "smashable"
			
func smash():
	$AudioStreamPlayer3D.stream = load("res://sound/pot_smash.ogg")
	$AudioStreamPlayer3D.play()
	var rand = randi_range(0, JsonData.item_data.size())
	var item_found = false
	for i in JsonData.item_data:
		if item_found == false:
			var dropPercent = randi_range(1, 100)
			print(str(i) + " : " + str(dropPercent) + "%")
			if JsonData.item_data[i]["Drop_Chance"] > 0 and dropPercent <= JsonData.item_data[i]["Drop_Chance"]:
				var item_drop_scene = load("res://objects/item_drop.tscn")
				var item_drop = item_drop_scene.instantiate()
				item_drop.item_name = i
				item_drop.global_position = global_position
				get_parent().add_child(item_drop)
				item_found = true
	smashed = true
	$smashed_sprite.visible = true
	$Pot.visible = false
	set_collision_layer_value(1, false)
		


func _on_input_event(camera, event, position, normal, shape_idx):
	if (event.is_action_pressed("click")
	and Globals.player.global_transform.origin.distance_to(global_transform.origin) <= Globals.player.range
	and smashed == false):
			smash()
