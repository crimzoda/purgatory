extends Node3D
var hitting = false
var can_fire = true
var arrow_scene = load("res://objects/arrow.tscn")
var item

func _process(delta):
	if Input.is_action_just_pressed("click") and can_fire == true:
		hitting = true
		$fire_timer.wait_time = JsonData.item_data["crossbow"]["Cooldown"]
		$AnimationPlayer.play("crossbow_animation")
		var arrow = arrow_scene.instantiate()
		arrow.global_position = Globals.player.global_position
		arrow.destination = Globals.player.get_mouse_3d()
		if arrow.destination != null:
			get_node("/root/Dungeon").add_child(arrow)
			can_fire = false
			$fire_timer.start()
			print("cooling down" + str(JsonData.item_data["crossbow"]["Cooldown"]))

func flip(direction):
	if direction == "right":
		$Sprite3D.set_flip_h(true)
		scale.x = -1
		transform.origin = Vector3(.266, 0, 0)
	else:
		$Sprite3D.set_flip_h(false)
		scale.x = 1
		transform.origin = Vector3(0, 0, 0)


func _on_fire_timer_timeout():
	can_fire = true
	print("cool down finished")
