extends Node2D

const Antique = preload("res://Scenes/Antique.tscn")
const Explosion = preload("res://Scenes/Explosion.tscn")
const COMPUTER = preload("res://Sprites/Computer.png")
const MODEM = preload("res://Sprites/Modem.png")
const WALKMAN = preload("res://Sprites/Walkman.png")
const VHS_TAPE = preload("res://Sprites/VHSTape.png")
const NES_CONTROLLER = preload("res://Sprites/NESController.png")
const TEXTURES = [COMPUTER, MODEM, WALKMAN, VHS_TAPE, NES_CONTROLLER]
const NAMES = ["Commodore64", "56k Modem", "Walkman", "VHS Tape", "NES"]

onready var game = $".."
onready var player = $"../Player"
onready var effects = $"../Effects"
onready var mlog = $"/root/Game/UI/Monologue"

var last_spawn = 0.0

func _process(delta):
	last_spawn += delta
	if last_spawn > get_spawn_interval():
		var antique = Antique.instance()
		var x = rand_range(16, game.RESOLUTION.x - 16)
		while abs(player.position.x - x) < 16 and player.position.y < 150:
			x = rand_range(16, game.RESOLUTION.x - 16)
		antique.position.x = x
		var idx = int(rand_range(0, len(TEXTURES)))
		antique.texture = TEXTURES[idx]
		antique.real_name = NAMES[idx]
		add_child(antique)
		last_spawn = 0.0

func explode_at(pos, real_name):
	var explosion = Explosion.instance()
	explosion.position = pos
	explosion.emitting = true
	effects.add_child(explosion)
	
	if player.rage_target == real_name:
		game.score(game.Scoring.DESTROYED, -1.0)
	else:
		game.score(game.Scoring.DESTROYED, 1.0)
	
	if player.rage_duration <= -player.RAGE_DURATION and randf() < 0.1:
		player.rage_target = real_name
		player.rage_duration = player.RAGE_DURATION
		mlog.show_message(mlog.Messages.RAGE, player.rage_target, true)

func get_spawn_interval():
	return 1 + 0.05 - 1 * game.scroll_speed / game.MAX_SCROLL_SPEED #(max - min) + min - speed / maxspeed
