class_name TutorialSign extends Node2D


# SIGNALS


signal playerFinishedLevel
signal playerCrossed(player)


# EXPORTS


export(Array, String, MULTILINE) var _dialogueText: Array = []
export(float, 0, 128, 8) var _hitboxHeight: float = 64 setget _setHitboxHeight
export(float, 0, 5, 0.1) var _promptDelayAfterDialogueExit: float = 0.8
export(bool) var _isLevelEnd: bool = false
export(float, 0, 10, 0.1) var _levelUnlockSfxDelay: float = 1


# VARS

var levelCanEnd: bool = false setget _setLevelCanEnd

onready var _dialoguePanel: PanelContainer = $UI/Canvas/Dialogue
onready var _dialogueBox: DialogueBox = $UI/Canvas/Dialogue/DialogueBox
onready var _promptPanel: PanelContainer = $UI/Canvas/Prompt
var _hasPlayer: bool = false


# METHODS - NODE PROCESSES


func _ready():
	self._hitboxHeight = _hitboxHeight
	_dialoguePanel.hide()
	_promptPanel.hide()

	if not _isLevelEnd:
		$MinimumPresentsBarrier/CollisionShape2D.disabled = true


# METHODS - SETTERS & GETTERS


func _setHitboxHeight(hitboxHeightValue: float) -> void:
	_hitboxHeight = hitboxHeightValue

	var hitbox: CollisionShape2D = $Area2D/CollisionShape2D
	if hitbox:
		var hitboxShape: RectangleShape2D = hitbox.shape
		hitboxShape.extents.y = _hitboxHeight / 2
		hitbox.position.y = -hitboxShape.extents.y

func _setLevelCanEnd(levelCanEndValue: bool) -> void:
	if levelCanEnd == levelCanEndValue:
		return

	levelCanEnd = levelCanEndValue

	$MinimumPresentsBarrier/CollisionShape2D.disabled = levelCanEnd
	if levelCanEnd:
		yield(get_tree().create_timer(_levelUnlockSfxDelay), "timeout")
		$NextLevelUnlockedSFX.play()


# METHODS - SIGNAL CALLBACKS


func _onPlayerEnteredSignArea(_body):
	_hasPlayer = true

	if not _isLevelEnd and _dialogueText.size():
		_promptPanel.show()
		return

	if levelCanEnd:
		$LevelEndSFX.play()
		emit_signal("playerFinishedLevel")

func _onPlayerExitedSignArea(body):
	_hasPlayer = false
	_dialogueBox.stopAndReset()

	emit_signal("playerCrossed", body)

# Player started reading the sign
func _onPlayerStartedReading(event):
	if (event is InputEventMouseButton
	and event.button_index == BUTTON_LEFT
	and not event.pressed
	and _dialogueText.size()):
		_promptPanel.hide()
		_dialoguePanel.show()
		_dialogueBox.talk(_dialogueText)

func _on_DialogueBox_dialogue_exit():
	_dialoguePanel.hide()
	yield(get_tree().create_timer(_promptDelayAfterDialogueExit), "timeout")

	if _hasPlayer:
		_promptPanel.show()
	else:
		_promptPanel.hide()
