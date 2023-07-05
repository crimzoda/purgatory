extends Node3D


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			for item in PlayerInventory.inventory:
				if PlayerInventory.inventory[item][0] == "dungeon_key":
					get_tree().quit()
