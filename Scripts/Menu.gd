extends Node2D

var time = 1.0

func _process(delta):
	time -= delta
	if Input.is_key_pressed(KEY_ENTER) and time < 0:
		get_tree().change_scene("res://Scenes/Game.tscn")