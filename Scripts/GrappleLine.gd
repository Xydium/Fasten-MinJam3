extends Line2D

onready var player = $".."

func _process(delta):
	if player.grappling:
		points[1] = player.grapple_target.position - player.position
	visible = player.grappling
