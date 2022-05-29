class_name StartScreenUI extends Control


# SIGNALS
signal startGame
signal exitGame

# EXPORTS
export(bool) var enabled = false setget setEnabled

func _ready():
	setEnabled(enabled)

func setEnabled(value: bool) -> void:
	enabled = value

	var startButton: Button = $Start/Button
	startButton.disabled = not value
	startButton.mouse_default_cursor_shape = CURSOR_POINTING_HAND if value else CURSOR_ARROW

	var exitButton: Button = $Exit/Button
	exitButton.disabled = not value
	exitButton.mouse_default_cursor_shape = CURSOR_POINTING_HAND if value else CURSOR_ARROW

func _on_StartButton_pressed():
	emit_signal("startGame")


func _on_ExitButton_pressed():
	emit_signal("exitGame")
