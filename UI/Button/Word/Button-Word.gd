extends Button


# VARS
var word: Word

# METHODS
func activateCorrectStyle() -> void:
	var correctStyle: StyleBoxFlat = load("res://UI/Button/Word/Button-Correct.tres")
	var correctIcon: Texture = load("res://assets/Sprites/quiz/correct.png")
	add_stylebox_override("disabled", correctStyle)
	icon = correctIcon

func activateWrongStyle() -> void:
	var wrongStyle: StyleBoxFlat = load("res://UI/Button/Word/Button-Wrong.tres")
	var wrongIcon: Texture = load("res://assets/Sprites/quiz/wrong.png")
	add_stylebox_override("disabled", wrongStyle)
	icon = wrongIcon
