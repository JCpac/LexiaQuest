class_name StartSign extends Node2D


# SIGNALS
signal playerHasCrossed

# EXPORTS
export(Array, String, MULTILINE) var dialogueText = [
	"If you're here, that means you're lost, right?",
	"Thats's OK. You can just go through this cave to find civilization again!",
	"A word of caution though. There's this mysterious timer that kills you if you stay in the cave for too long.",
	"Feel free to explore, of course. Just... Don't stick around for too long.",
	"Good luck! The timer starts once you cross this sign."
]

# VARS
onready var dialogue: PanelContainer = $UI/Dialogue
onready var dialogueBox: DialogueBox = $UI/Dialogue/DialogueBox
onready var prompt: PanelContainer = $UI/Prompt
var hasPlayer: bool = false

func _input(event):
	if event.is_action_pressed("ui_accept") and hasPlayer:
		if not dialogue.visible:
			prompt.hide()
			dialogue.show()
			dialogueBox.talk(dialogueText)

func _ready():
	dialogue.hide()
	prompt.hide()

func _on_DialogueBox_dialogue_exit():
	dialogue.hide()

	if hasPlayer:
		prompt.show()


func _on_Area2D_body_entered(_body):
	hasPlayer = true
	prompt.show()


func _on_Area2D_body_exited(body):
	hasPlayer = false
	prompt.hide()
	dialogue.hide()

	# Only emit signal if player crossed to the right of the sign
	if body.position.x > position.x:
		emit_signal("playerHasCrossed")
