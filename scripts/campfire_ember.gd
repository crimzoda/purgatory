extends CharacterBody3D

const MAX_SPEED = 25
const ACCELERATION = 50

func _physics_process(delta):
	var direction = global_transform.origin.direction_to(Globals.player.global_transform.origin)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
	var distance = global_transform.origin.distance_to(Globals.player.global_transform.origin)
	if distance < 1.5:
		queue_free()
	move_and_slide()
