extends Sprite

const PIXELS_TO_LOOP = 16
const SPEED_FACTOR = 0.1

onready var game = $"/root/Game"

func _process(delta):
	scroll_background(delta)

func scroll_background(delta):
	offset.y += game.scroll_speed * SPEED_FACTOR * PIXELS_TO_LOOP * delta
	offset.y = fmod(offset.y, PIXELS_TO_LOOP)
