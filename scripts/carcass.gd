extends Sprite3D

@export var audio : AudioStream

func _ready():
	$AudioStreamPlayer3D.stream = audio
	$AudioStreamPlayer3D.play()
