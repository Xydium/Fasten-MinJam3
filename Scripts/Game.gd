extends Node2D

const RESOLUTION = Vector2(432/2, 768/2)
const MAX_SCROLL_SPEED = 200
const MAX_DISTANCE = MAX_SCROLL_SPEED * 100

#Raw amounts, multiplied by a factor
enum Scoring {
	SURVIVED = 10,
	GRAPPLED = 100,
	BOOSTED = 50,
	FULL_CIRCLE = 2500,
	DESTROYED = -5000
}

onready var mlog = $UI/Monologue

var scroll_speed = 1 setget set_scroll_speed
var distance = 0.0
var score = 0.0
var done = false

func _ready():
	randomize()

func _process(delta):
	distance += scroll_speed * delta
	if distance >= MAX_DISTANCE and not done:
		done = true
		$UI/Monologue/Anim.stop()
		$UI/Monologue/Speak.stop()
		$UI/Veil.visible = true
		$UI/Veil/Score.text = str(int(score * (1 + MAX_DISTANCE / ($UI/Base/Time.time * MAX_SCROLL_SPEED))))
		$UI/Veil/Anim.play("FadeIn")
		$Victory.play()
	elif done:
		if Input.is_key_pressed(KEY_ENTER):
			get_tree().change_scene("res://Scenes/Menu.tscn")
	
	if rand_range(0, 100) < 1:
		mlog.show_message(mlog.Messages.RANDOM)

func set_scroll_speed(value):
	scroll_speed = clamp(value, 1, MAX_SCROLL_SPEED)

func score(base_value, multiplier):
	score += base_value * multiplier
	score = max(0, score)