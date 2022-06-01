class_name ButtonQuiz extends Button


# VARS
var isCorrect: bool

# METHODS
func setUp(value: String, correct: bool) -> void:
	text = value
	isCorrect = correct
	disabled = false
	_clearStyles()

func _clearStyles() -> void:
	add_stylebox_override("disabled", null)
	$MarginContainer/TextureRect.texture = null

func revealState(wasChosen: bool) -> void:
	disabled = true

	if isCorrect:
		_setCorrect()
		return

	_setWrong(wasChosen)

func _setCorrect() -> void:
	var correctStyle: StyleBoxFlat = load("res://UI/Button/Button-Correct.tres")
	var correctIcon: Texture = load("res://assets/Sprites/quiz/correct.png")
	add_stylebox_override("disabled", correctStyle)
	$MarginContainer/TextureRect.texture = correctIcon

func _setWrong(wasChosen: bool) -> void:
	if wasChosen:
		_setWrongStyle()

	_setWrongIcon()

func _setWrongStyle() -> void:
	var wrongStyle: StyleBoxFlat = load("res://UI/Button/Button-Wrong.tres")
	add_stylebox_override("disabled", wrongStyle)

func _setWrongIcon() -> void:
	var wrongIcon: Texture = load("res://assets/Sprites/quiz/wrong.png")
	$MarginContainer/TextureRect.texture = wrongIcon
