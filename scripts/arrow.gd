extends Area3D
var SPEED = 20

var destination
var damage = 10
var target
var type = "projectile"

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(destination)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += -global_transform.basis.z * SPEED * delta


func _on_queue_free_timer_timeout():
	queue_free()
	print("removing")

func _on_body_entered(body):
	if body.get("type") != null:
		if body.get("type") != "player":
			if body.get("type") == "smashable" and body.smashed == false:
				body.smash()
			else:
				body.damage(damage)
	print(str(body))
	if body.get("type") != "player":
		queue_free()
