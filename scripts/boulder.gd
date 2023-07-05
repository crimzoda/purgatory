extends RigidBody3D
@onready var falling = true

func _ready():
	$AudioStreamPlayer3D.stream = load("res://sound/boulder_fall.ogg")
	$AudioStreamPlayer3D.play()

func _on_area_3d_body_entered(body):
	if body.get("type") != null and body is GridMap == false and falling == true:
		if body.get("type") == "player":
			body.get_node("AudioStreamPlayer3D").stream = load("res://sound/boulder_impact.ogg")
			body.get_node("AudioStreamPlayer3D").play()
		else:
			$AudioStreamPlayer3D.stream = load("res://sound/boulder_impact.ogg")
			$AudioStreamPlayer3D.play()
		body.damage(1000)
		print("did 100 damage to " + str(body))
	elif  body.get("type") != null and body is GridMap == false and falling == false and linear_velocity.length() >= 1:
		$AudioStreamPlayer3D.stream = load("res://sound/boulder_impact.ogg")
		$AudioStreamPlayer3D.play()
		body.damage(1000)
		print("did 100 damage to " + str(body))
	if body is GridMap:
		falling = false
		$AudioStreamPlayer3D.stream = load("res://sound/boulder_impact.ogg")
		$AudioStreamPlayer3D.play()
