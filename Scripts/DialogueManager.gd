extends Control
class_name DialogueManager

@onready var speech_bubble = $SpeechBubble1
@onready var text_label = $SpeechBubble1/Text1

var voice_lines_entering: Array[String] = [
	"I am going to kill yuo >:3",
	"I love you <3",
	"I have bomb........jk",
	"Screw u dude"
]

var voice_lines_leaving_bad: Array[String] = [
	"Whatever man", 
	"Okay, I guess...", 
	"Screw u dude",
	"Wow, figures.",
	"yurp",
	"sugma"
]

var voice_lines_leaving_good: Array[String] = [
	"yay",
	"yippee!",
	"Big mistake buster",
	"Lets GOOOOOO DOOD",
	"yoy"
]

func show_greeting() -> void:
	speech_bubble.modulate.a = 1.0
	text_label.text = voice_lines_entering[randi() % voice_lines_entering.size()]

func show_dismissal(decision: String) -> void:
	text_label.text = ""
	if decision == "approved":
		text_label.text = voice_lines_leaving_good[randi() % voice_lines_leaving_good.size()]
	elif decision == "denied":
		text_label.text = voice_lines_leaving_bad[randi() % voice_lines_leaving_bad.size()]
	
	var fade_tween = create_tween()
	fade_tween.tween_property(speech_bubble, "modulate:a", 0.0, 3.5)

func clear() -> void:
	text_label.text = ""
