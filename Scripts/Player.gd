extends Sprite

const GRAPPLE_PULL = 200 #px/sec/sec
const FREE_MOVE_ACCEL = 200 #px/sec/sec
const GRAPPLE_TOLERANCE = 32 #px
const BOOST_FACTOR = 0.1
const MIN_GRAPPLE_RADIUS = 32 #px
const RAGE_DURATION = 60 #sec
const RESTORE_STRENGTH = 4
const DIR = {
	"OrbitUp": Vector2(0, -1),
	"OrbitLeft": Vector2(-1, 0),
	"OrbitDown": Vector2(0, 1),
	"OrbitRight": Vector2(1, 0)
}

onready var game = $"/root/Game"
onready var mlog = $"/root/Game/UI/Monologue"
onready var spawn_pos = Vector2(game.RESOLUTION.x / 2, game.RESOLUTION.y - 124)

var grappling = false
var grapple_target = null
var grapple_speed = 0
var grapple_radius = INF
var grapple_boost_on_release = 0
var grapple_orbit = false
var grapple_dtheta = 0.0
var rage_target = null
var rage_duration = -RAGE_DURATION

var velocity = Vector2(0, 0)
var restore_velocity = Vector2(0, 0)

func _ready():
	position = spawn_pos
	$Anim.play("Fly")

func _process(delta):
	if game.done: return
	check_for_grapple()
	if not grappling:
		game.scroll_speed *= 0.995
		return_to_spawn_position(delta)
	else:
		orbit_grapple(delta)
		check_for_ungrapple()
	var rage_positive = rage_duration > 0
	rage_duration -= delta
	if rage_duration < 0.0 and rage_positive:
		rage_target = null
		mlog.show_message(mlog.Messages.END_RAGE, "", true)

func check_for_grapple():
	if Input.is_action_just_pressed("Grapple"):
		var grapple_position = get_global_mouse_position()
		if(grapple_position.y > position.y): return
		for antique in game.get_node("Antiques").get_children():
			if antique.position.distance_to(grapple_position) < GRAPPLE_TOLERANCE and not antique.is_queued_for_deletion():
				if(grapple_target != null): grapple_target.grappled = false
				grapple_target = antique
				grapple_target.grappled = true
				$Anim.play("Grapple")
				game.score(game.Scoring.GRAPPLED, 1 + position.distance_to(antique.position) / 100)
				flip_h = grapple_target.position.x > position.x
				grapple_speed = restore_velocity.y
				if flip_h and grapple_speed > 0 or not flip_h and grapple_speed < 0:
					grapple_speed *= -1
				grapple_radius = INF
				$GrappleOn.play()
				mlog.show_message(mlog.Messages.GRAPPLE, antique.real_name)
				break
		grappling = grapple_target != null
		if not grappling:
			$GrappleMissed.play()

func check_for_ungrapple():
	if Input.is_action_just_pressed("UnGrapple") and grappling:
		$Anim.play("Fly")
		flip_h = false
		if grapple_boost_on_release > 0:
			if abs(position.y - grapple_target.position.y) < 16:
				$SuperBoostUp.play()
				grapple_boost_on_release *= 3
			else:
				$BoostUp.play()
		else:
				$BoostDown.play()
		ungrapple()

func ungrapple():
	velocity *= 2
	grappling = false
	grapple_target.grappled = false
	grapple_target = null
	grapple_radius = INF
	grapple_speed = 0
	game.scroll_speed += grapple_boost_on_release * BOOST_FACTOR
	game.score(game.Scoring.BOOSTED, grapple_boost_on_release * BOOST_FACTOR)
	grapple_dtheta = 0.0
	grapple_boost_on_release = 0
	grapple_dtheta = 0.0
	grapple_orbit = false

#Forgive me for this code, Flying Spaghetti Monster...
func orbit_grapple(delta):
	grapple_radius = min(grapple_radius, (grapple_target.position - position).length())
	grapple_speed = clamp(grapple_speed, -GRAPPLE_PULL * 3, GRAPPLE_PULL * 3)
	if grapple_radius < MIN_GRAPPLE_RADIUS:
		grapple_radius = MIN_GRAPPLE_RADIUS
		grapple_orbit = true
	if position.y > grapple_target.position.y and not grapple_orbit:
		grapple_speed += GRAPPLE_PULL * delta * sign(position.x - grapple_target.position.x)
		grapple_boost_on_release = abs(grapple_speed)
		velocity = Vector2(0, -abs(grapple_speed))
		position += velocity * delta
	else:
		grapple_orbit = true
		var sum_vec = Vector2(0, 0)
		for dir in DIR.keys():
			var vec = DIR[dir]
			if Input.is_action_pressed(dir):
				sum_vec += vec
		var rot_vec = (grapple_target.position - position).normalized().rotated(PI/2)
		if sum_vec.length() > 0.1:
			var dp = rot_vec.dot(sum_vec)
			if dp > 0.3:
				grapple_speed += GRAPPLE_PULL * delta
			elif dp < -0.3:
				grapple_speed -= GRAPPLE_PULL * delta
			else:
				grapple_speed *= 0.95
		velocity = rot_vec * grapple_speed
		grapple_boost_on_release = -velocity.y
		var theta = position.angle_to_point(grapple_target.position)
		position += velocity * delta
		position = (position - grapple_target.position).normalized() * grapple_radius + grapple_target.position
		grapple_dtheta += abs(position.angle_to_point(grapple_target.position) - theta)
		if grapple_dtheta > 2*PI:
			game.score(game.Scoring.FULL_CIRCLE, 1.0)
			grapple_dtheta = 0

func return_to_spawn_position(delta):
	var unlerped = Vector2(position)
	velocity.x *= 0.97
	velocity.y *= 0.99
	position += velocity * delta
	position.x = lerp(position.x, spawn_pos.x, RESTORE_STRENGTH * delta)
	position.y = lerp(position.y, spawn_pos.y, RESTORE_STRENGTH * delta)
	restore_velocity = (position - unlerped) / delta

func free_move(delta):
	var accel = Vector2(0, 0)
	var is_accel = false
	for dir in DIR.keys():
		if Input.is_action_pressed(dir):
			accel += DIR[dir]
			is_accel = true
	velocity += accel * FREE_MOVE_ACCEL * delta
	return is_accel

func clamp_to_screen():
	var unclamped = position
	position.x = clamp(position.x, 0, game.RESOLUTION.x)
	position.y = clamp(position.y, 0, game.RESOLUTION.y)
	return unclamped != position