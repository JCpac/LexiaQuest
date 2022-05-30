class_name EndScreenUI extends Control


# SIGNALS
signal nextLevel
signal restartLevel
signal backToStartScreen

# EXPORTS
export(bool) var enabled = false setget _setEnabled
export(String, MULTILINE) var message = "Your message here..." setget _setMessage
export(bool) var showNextLevelButton = true setget _setShowNextLevelButton

# VARS
onready var messageLabel: RichTextLabel = $VBoxContainer/MarginContainer/Message
onready var nextLevelButton: Button = $VBoxContainer/Options/Next
onready var restartLevelButton: Button = $VBoxContainer/Options/Restart
onready var backButton: Button = $VBoxContainer/Options/Back

# METHODS
func _ready():
	# Call setters
	# (UI nodes won't be affected if setters are called before they're ready,
	# which can happen if exported variables have non-default values)
	_setEnabled(self.enabled)
	_setMessage(self.message)
	_setShowNextLevelButton(self.showNextLevelButton)

func _setMessage(text: String) -> void:
	message = text

	if self.messageLabel:
		self.messageLabel.bbcode_text = "[center]%s[/center]" % text

func _setShowNextLevelButton(showButton: bool) -> void:
	showNextLevelButton = showButton

	if self.nextLevelButton:
		self.nextLevelButton.visible = showButton

func _setEnabled(value: bool) -> void:
	enabled = value

	if self.nextLevelButton:
		self.nextLevelButton.disabled = not value
		self.nextLevelButton.mouse_default_cursor_shape = CURSOR_POINTING_HAND if value else CURSOR_ARROW

	if self.restartLevelButton:
		self.restartLevelButton.disabled = not value
		self.restartLevelButton.mouse_default_cursor_shape = CURSOR_POINTING_HAND if value else CURSOR_ARROW

	if self.backButton:
		self.backButton.disabled = not value
		self.backButton.mouse_default_cursor_shape = CURSOR_POINTING_HAND if value else CURSOR_ARROW

func _on_Next_pressed():
	emit_signal("nextLevel")

func _on_Restart_pressed():
	emit_signal("restartLevel")

func _on_Back_pressed():
	emit_signal("backToStartScreen")
