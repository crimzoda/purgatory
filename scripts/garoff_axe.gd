extends Area3D

var SPEED = 20

var destination
var retrieving = false
var garoff

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(destination)
	$AnimationPlayer.play("garoff_axe_spin")
	$AudioStreamPlayer3D.stream = load("res://sound/garoff_axe_swing.ogg")
	$AudioStreamPlayer3D.play()
	
func _process(delta):
	if global_position.distance_to(destination) > 1:
		global_position += -global_transform.basis.z * SPEED * delta
	elif garoff.axe != self and garoff.global_position.distance_to(destination) > 2:
		global_position = global_position
		$AnimationPlayer.pause()
		garoff.axe = self
		garoff.set_state("roaming")
		garoff.get_node("NavigationAgent3D").target_position = Vector3.ZERO
		$AudioStreamPlayer3D.stream = load("res://sound/garoff_axe_impact.ogg")
		$AudioStreamPlayer3D.play()
	if garoff.global_position.distance_to(destination) < 2:
		garoff.get_node("Sprite3D").texture = load("res://textures/garoff_holding_axe.png")
		garoff.axe = null
		queue_free()


func _on_body_entered(body):
	if body.get("type") != null:
		body.damage(50)
		print("did damage to " + str(body.get("type")))
