extends Control

var dragPoint = null
@onready var shop_owner = get_parent()

func _on_btn_close_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				get_parent().get_node("Shop_window").visible = !get_parent().get_node("Shop_window").visible

func _process(delta):
	if get_parent().global_position.distance_to(Globals.player.global_position) > 5 and visible == true:
		visible = false

func _on_dragbar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragPoint = get_global_mouse_position() - get_parent().get_node("Shop_window").get_position()
			else:
				dragPoint = null
	if event is InputEventMouseMotion and dragPoint != null:
		get_parent().get_node("Shop_window").set_position(get_global_mouse_position() - dragPoint)


func _on_visibility_changed():
	if is_visible_in_tree():
		Globals.player.can_trade = true
		print("opening")
	else:
		Globals.player.can_trade = false
		print("closing")


func _on_area_2d_mouse_entered():
	Globals.player.can_hit = false
	print("mouse entered")


func _on_area_2d_mouse_exited():
	Globals.player.can_hit = true
	print("mouse entered")
