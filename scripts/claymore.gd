extends Node3D
var hitting = false
var item

func _process(delta):
	if Input.is_action_just_pressed("click") and Globals.player.can_hit == true:
		hitting = true
		$hit_timer.wait_time = JsonData.item_data["claymore"]["Cooldown"]
		$AnimationPlayer.play("claymore_animation")
		Globals.player.can_hit = false
		$hit_timer.start()
		print("cooling down" + str(JsonData.item_data["claymore"]["Cooldown"]))

func flip(direction):
	if direction == "right":
		$Sprite3D.set_flip_h(true)
		scale.x = -1
		transform.origin = Vector3(.266, 0, 0)
	else:
		$Sprite3D.set_flip_h(false)
		scale.x = 1
		transform.origin = Vector3(0, 0, 0)

func _on_hit_timer_timeout():
	Globals.player.can_hit = true
	print("cool down finished")
