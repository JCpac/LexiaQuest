class_name ButtonLetter extends Button


# METHODS
func setUp(value: String) -> void:
	text = value
	disabled = false
	_clearStyles()

func _clearStyles() -> void:
	add_stylebox_override("disabled", null)
	$MarginContainer/TextureRect.texture = null

func setCorrect() -> void:
	var correctStyle: StyleBoxFlat = load("res://UI/Button/Button-Correct.tres")
	var correctIcon: Texture = load("res://assets/Sprites/quiz/correct.png")
	add_stylebox_override("disabled", correctStyle)
	$MarginContainer/TextureRect.texture = correctIcon
	disabled = true

func setPossible() -> void:
	var possibleIcon: Texture = load("res://assets/Sprites/quiz/possible.png")
	$MarginContainer/TextureRect.texture = possibleIcon
	disabled = true

func setWrong(wasChosen: bool) -> void:
	if wasChosen:
		_setWrongStyle()

	_setWrongIcon()
	disabled = true

func _setWrongStyle() -> void:
	var wrongStyle: StyleBoxFlat = load("res://UI/Button/Button-Wrong.tres")
	add_stylebox_override("disabled", wrongStyle)

func _setWrongIcon() -> void:
	var wrongIcon: Texture = load("res://assets/Sprites/quiz/wrong.png")
	$MarginContainer/TextureRect.texture = wrongIcon
