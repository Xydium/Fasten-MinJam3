extends Node

func _ready():
	init_viewport_size()

func init_viewport_size():
	var size = OS.window_size / 2
	get_parent().set_size_override(true, size)
	get_parent().set_size_override_stretch(true)