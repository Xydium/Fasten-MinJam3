extends Sprite

const SPIN_RATE = 60 #dgr/sec
const MIN_SPEED = 40 #px/sec
const MIN_SAFE_DISTANCE = 10 #px

onready var game = $"/root/Game"
onready var player = $"/root/Game/Player"
onready var mlog = $"/root/Game/UI/Monologue"

var grappled = false
var real_name
var destroyed = false

func _process(delta):
	if destroyed or game.done: return
	rotation_degrees += SPIN_RATE * delta
	if not grappled:
		position.y += (MIN_SPEED + game.scroll_speed * 2) * delta
	if position.distance_to(player.position) < MIN_SAFE_DISTANCE:
		if player.grappling:
			player.grapple_speed  *= 0.25
		else:
			game.scroll_speed -= 50
		$"..".explode_at(position)
		mlog.show_message(mlog.Messages.DESTROYED, real_name)
		destroyed = true
		queue_free()