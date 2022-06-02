class_name TutorialSign extends Node2D


# EXPORTS


export(Array, String, MULTILINE) var dialogueText: Array = []
export(float, 0, 5, 0.1) var _promptDelayAfterDialogueExit: float = 0.8


# VARS


onready var _dialoguePanel: PanelContainer = $UI/Canvas/Dialogue
onready var _dialogueBox: DialogueBox = $UI/Canvas/Dialogue/DialogueBox
onready var _promptPanel: PanelContainer = $UI/Canvas/Prompt
var _hasPlayer: bool = false


# METHODS - NODE PROCESSES


func _ready():
	_dialoguePanel.hide()
	_promptPanel.hide()


# METHODS - SIGNAL CALLBACKS


func _onPlayerEnteredSignArea(_body):
	_hasPlayer = true
	_promptPanel.show()

func _onPlayerExitedSignArea(_body):
	_hasPlayer = false
	_dialogueBox.stopAndReset()

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
	yield(get_tree().create_timer(_promptDelayAfterDialogueExit), "timeout")

	if _hasPlayer:
		_promptPanel.show()
	else:
		_promptPanel.hide()
