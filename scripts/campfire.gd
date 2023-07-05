extends StaticBody3D

var healing = false

func _process(delta):
	if Globals.player.global_position.distance_to(global_position) < 4:
		$RayCast3D.target_position = Globals.player.global_position - $RayCast3D.global_position
		if $RayCast3D.get_collider() == Globals.player:
			healing = true
		else:
			healing = false
	else:
		healing = false


func _on_heal_timer_timeout():
	if healing == true:
		if Globals.player.health < Globals.player.max_health:
			var ember_scene = load("res://objects/campfire_ember.tscn")
			var ember = ember_scene.instantiate()
			add_child(ember)
			Globals.player.health = Globals.player.health + 2
