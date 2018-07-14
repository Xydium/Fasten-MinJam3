extends Polygon2D

const CHARS_PER_LINE = 20
const LINES = 3
const CHARS_PER_SCREEN = CHARS_PER_LINE * LINES

const FR = "____________________________________________________________"

var queue = []

const Messages = {
	GRAPPLE = [
		"Why do I have so many %ss?",
		"I had a %s before they were cool.",
		"This %s will be worth a lot in 40 years.",
		"I've been looking for this %s forever!",
		"Can't believe I kept this %s.",
		"I wonder if this %s still works.",
		"Kids these days don't appreciate a good %s.",
		"Back in my day, everyone envied my %s."
	],
	DESTROYED = [
		"I could've sold that %s!",
		"Well, that's one less %s.",
		"That's allota damage! Sorry, %s.",
		"I'll need duct tape to fix that %s.",
		"I sawed this %s in half!",
		"*slaps %s* That bad boy could fit so much nostalgia.",
		"Even with 140 IQ I can't understand a %s."
	],
	RANDOM = [
		"When I sell these I can finally stop eating ramen.%s",
		"My ex made me choose between her and these.%s",
		"Some call it hoarding; I call it investing.%s",
		"It's not an addiction, I can stop when I want to.%s",
		"I'm not a 'loser geek', I'm a 'tech enthusiast'.%s",
		"At least I don't have a Macintosh.%s",
		"I've been involved in numerous secret Warcraft raids.%s",
		"Alexa, play D&D. ~NOW PLAYING DESPACITO 2~ ALEXA, NO!%s",
		"There is no way to tell what is satire online anymore.%s",
		"Waluigi is FAR too powerful to be put in a Smash Bros game.%s",
		"iPhone is the best console, and nobody can speak against it.%s",
		"AAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAA%s"
	],
	RAGE = [
		"Y'know, %ss weren't that good. Destroy them!"
	],
	END_RAGE = [
		"Alright, that's enough destruction for now.%s"
	]
}

func _process(delta):
	if not queue.empty() and not $Anim.is_playing():
		var entry = queue.pop_front()
		show_message(entry[0], entry[1])

func show_message(message, antique_name = "", should_queue = false):
	if $Anim.is_playing(): 
		if should_queue: queue.append([message, antique_name])
		return
	$Text.text = message[int(rand_range(0, len(message)))] % antique_name
	$Anim.play("ShowText")