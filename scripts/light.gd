extends Area3D

var type = "light"

func _ready():
	await get_tree().create_timer(randf_range(0, 1)).timeout
	$AnimationPlayer.play("light_flicker")
