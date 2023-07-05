extends Control

func show_tooltip(description, _position):
	$ColorRect/Label.text = description
	global_position = _position
	visible = true
