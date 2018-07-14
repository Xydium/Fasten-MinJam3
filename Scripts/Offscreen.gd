extends Sprite

onready var game = $"/root/Game"
onready var player = $"/root/Game/Player"

func _process(delta):
	if not onscreen():
		visible = true
		position.x = clamp(player.position.x, 16, game.RESOLUTION.x - 16)
		position.y = clamp(player.position.y, 16, game.RESOLUTION.y - 16)
		rotation = (player.position - position).angle()
	else:
		visible = false

func onscreen():
	var p = player.position
	return p.x > -4 and p.x < game.RESOLUTION.x + 4 and p.y > -4 and p.y < game.RESOLUTION.y + 4
