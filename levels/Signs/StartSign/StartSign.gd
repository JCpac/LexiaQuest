class_name StartSign extends Node2D


# SIGNALS


signal playerHasCrossed


# EXPORTS


export(Array, String, MULTILINE) var dialogueText = []


# VARS


onready var _dialoguePanel: PanelContainer = $UI/Dialogue
onready var _dialogueBox: DialogueBox = $UI/Dialogue/DialogueBox
onready var _promptPanel: PanelContainer = $UI/Prompt
var _hasPlayer: bool = false


# METHODS - NODE PROCESSES


func _ready():
	_dialoguePanel.hide()
	_promptPanel.hide()


# METHODS - SIGNAL CALLBACKS


func _onPlayerEnteredSignArea(_body):
	_hasPlayer = true
	_promptPanel.show()

func _onPlayerExitedSignArea(body):
	_hasPlayer = false
	_dialogueBox.stopAndReset()

	# Only emit signal if player crossed to the right of the sign
	if body.position.x > position.x:
		emit_signal("playerHasCrossed")

# Player started reading the sign
func _onPlayerStartedReading(event):
	if (event is InputEventMouseButton
	and event.button_index == BUTTON_LEFT
	and not event.pressed
	and dialogueText.size()):
		_promptPanel.hide()
		_dialoguePanel.show()
		_dialogueBox.talk(dialogueText)

func _on_DialogueBox_dialogue_exit():
	_dialoguePanel.hide()

	if _hasPlayer:
		_promptPanel.show()
	else:
		_promptPanel.hide()
