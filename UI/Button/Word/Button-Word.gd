extends Button


# VARS
var word: Word

# METHODS
func setCorrect() -> void:
	var correctStyle: StyleBoxFlat = load("res://UI/Button/Word/Button-Correct.tres")
	var correctIcon: Texture = load("res://assets/Sprites/quiz/correct.png")
	add_stylebox_override("disabled", correctStyle)
	icon = correctIcon
	disabled = true

func setWrong(wasChosen: bool) -> void:
	if wasChosen:
		_setWrongStyle()

	_setWrongIcon()
	disabled = true

func _setWrongStyle() -> void:
	var wrongStyle: StyleBoxFlat = load("res://UI/Button/Word/Button-Wrong.tres")
	add_stylebox_override("disabled", wrongStyle)

func _setWrongIcon() -> void:
	var wrongIcon: Texture = load("res://assets/Sprites/quiz/wrong.png")
	icon = wrongIcon
