class_name EndScreenUI extends Control


# SIGNALS
signal restartGame
signal backToStartScreen

# EXPORTS
export(bool) var enabled = false setget setEnabled
export(String, MULTILINE) var text = "Your message here..." setget setText, getText

func _ready():
	setEnabled(enabled)

func setEnabled(value: bool) -> void:
	enabled = value
	$Restart/Button.disabled = not value
	$Back/Button.disabled = not value

	if value:
		$Restart/Button.grab_focus()


func setText(newText: String) -> void:
	$Message.bbcode_text = "[center]%s[/center]" % newText

func getText() -> String:
	return $Message.text

func _on_RestartButton_pressed():
	emit_signal("restartGame")

func _on_BackButton_pressed():
	emit_signal("backToStartScreen")
