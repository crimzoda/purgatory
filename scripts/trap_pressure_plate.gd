extends Node3D
var activated = false

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.get("type") != null and body is GridMap == false and activated == false:
		var boulder_scene = load("res://objects/boulder.tscn")
		var boulder = boulder_scene.instantiate()
		boulder.global_position = Vector3(global_position.x, global_position.y + 8, global_position.z)
		get_parent().add_child(boulder)
		$AnimationPlayer.play("pressure_plate_activated")
		activated = true
