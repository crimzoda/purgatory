extends Node3D
var status = "closed"
var colliding = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event.is_action_pressed("interact") and colliding == false:
		if status == "closed":
			door_open()
		else:
			door_close()
				
func door_open():
	var material = $Door0.get_surface_override_material(0).duplicate()
	material.albedo_color = Color(1, 1, 1, 0.3)
	$Door0.set_surface_override_material(0, material)
	$Door0/StaticBody3D.set_collision_layer(2)
	get_node("nav_obstacle").queue_free()
	$Door0/StaticBody3D.set_collision_layer_value(2, false)
	$Door0/StaticBody3D.set_collision_layer_value(3, true)
	$Door0/StaticBody3D.set_collision_layer_value(1, false)
	status = "opened"
	
func door_close():
	var material1 = $Door0.get_surface_override_material(0).duplicate()
	#rotation_degrees = Vector3(rotation_degrees.x, rotation_degrees.y - 90, rotation_degrees.z)
	material1.albedo_color = Color(1, 1, 1, 1)
	$Door0.set_surface_override_material(0, material1)
	$Door0/StaticBody3D.set_collision_layer(1)
	var nav_obstacle = NavigationObstacle3D.new()
	nav_obstacle.name = "nav_obstacle"
	add_child(nav_obstacle)
	$Door0/StaticBody3D.set_collision_layer_value(2, true)
	$Door0/StaticBody3D.set_collision_layer_value(3, false)
	$Door0/StaticBody3D.set_collision_layer_value(1, true)
	status = "closed"

func _on_area_3d_body_entered(body):
	if body is GridMap == false and body is StaticBody3D == false and colliding == false:
		colliding = true


func _on_area_3d_body_exited(body):
	if colliding == true:
		colliding = false
