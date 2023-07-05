extends Camera3D
var mouse_sens = 0.3
var camera_anglev = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			transform.origin.y -= 1
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			transform.origin.y += 1

func get_3d_mouse(position):
	return project_position(position, Globals.player.global_position.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
