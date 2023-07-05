extends Control


func _on_btn_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/dungeon.tscn")
