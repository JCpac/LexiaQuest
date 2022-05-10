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
	$Start/Button.disabled = not value
	$Exit/Button.disabled = not value

	if value:
		$Start/Button.grab_focus()

func _on_StartButton_pressed():
	emit_signal("startGame")


func _on_ExitButton_pressed():
	emit_signal("exitGame")
